"""
    This function returns the hellinger distance calculated in n (10 by default) different intervals of a trajectory together with its error. The normalization factor associated with the distribution in `q` is passed as an argument.
    Example:
    ```
    julia> hellingerdistance(data, parameters, normalizationfactor, n)
    ```
    """
function hellingerdistance(data::Matrix{Float64}, parameters::Parameters, normalizationfactor::Float64, n = 10)
   
    beta = 1./parameters.T

    function jointdistribution(x::Vector{Float64})
        q,p,z = x
        rhoq = 1./normalizationfactor*exp(-beta*parameters.potential.f(q))
        rhop = sqrt(beta/(2.*pi))*exp(-beta*p.^2/2.)
        rhoz = parameters.thermo.distribution(z)

        rhoq*rhop*rhoz
    end

    time = zeros(n)
    hell = zeros(n)
    error = zeros(n)
    data = data[1:100:end,:] ##The 100 factor increases the sampling time by this factor
    len = size(data)[1] - 1

    for i in 1:n
        data1 = data[1:Int(len/n*i),:]
        time[i] = data1[:,1][end]
        dens = sm[:nonparametric][:KDEMultivariate](data = data1[:,2:4], var_type = "ccc")

        function kernel(x::Vector{Float64})
            dens[:pdf](x)[1]
        end

        k_2(x) = kernel(x)^0.5
        j_2(x) = jointdistribution(x)^0.5

        hellinger(x) = 2.*(k_2(x) - j_2(x))^2.

        q1, q2 = (minimum(data1[:,2]),maximum(data1[:,2]))
        p1, p2 = (minimum(data1[:,3]),maximum(data1[:,3]))
        z1, z2 = (minimum(data1[:,4]),maximum(data1[:,4]))
        hell[i], error[i] = hcubature(hellinger, [q1,p1,z1],[q2,p2,z2], reltol = 1.0e-2)
        println(i)
    end

 

    results = hcat(time, hell)
    hellinger_results = hcat(results, error)
end
