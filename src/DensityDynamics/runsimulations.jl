function writeattributes(file, p::Parameters)
    attrs(file)["Integrator"] = p.integrator.name
    attrs(file)["Thermostat"] = p.thermo.name
    attrs(file)["Potential"] = p.potential.name
    attrs(file)["nsteps"] = p.nsteps
    attrs(file)["dtsampling"] = p.dtsampling
    attrs(file)["dtintegration"] = p.dt
    attrs(file)["Q"] = p.Q
    attrs(file)["T"] = p.T
    attrs(file)["nsimulations"] = p.nsimulations
end

"""
A .hdf5 file is generated where the lyapunov spectrum for each initial condition (nsimulations = number of initial conditions) is saved.
"""
function lyapunov_exponents(p::Parameters)
    
    try
        mkdir("../data")
    end
    
    filename = randstring(5)
    
    file = h5open("../data/lyap$(filename).hdf5", "w")
    writeattributes(file,p)
    close(file)
    
    for i in 1:p.nsimulations
        file = h5open("../data/lyap$(filename).hdf5", "r+")

        init, exp1,exp2,exp3 = lyapunov_simulation(p)
        file["simulation-$i/initialcond"] = init
        file["simulation-$i/exponent1"] = exp1
        file["simulation-$i/expoonent2"] = exp2
        file["simulation-$i/exponent3"] = exp3
        println("Simulation$i done")
        close(file)
    end

    println("File lyap$(filename).hdf5 succesfully generated. See file in ../data/")
end


"""
    A long trajectory is generated by parts (coincident with nsimulations) and saved in an .hdf5  file 
"""
function trajectory(p::Parameters)

    try
        mkdir("../data")
    end
    
    filename = randstring(5)

    beta = 1./p.T
    r0 = initcond(beta, p.Q)
    tx = trajectory_simulation(p, r0)
    r0 = tx[end,:][2:end]
    println("Part 1 done. ")

    for i in 2:p.nsimulations
        traj = trajectory_simulation(p, r0)
        traj = traj[2:end,:]
        traj[:,1] += (i-1)*p.nsteps*p.dt
        tx = vcat(tx, traj)
        r0 = traj[end,:][2:end]
        println("Part $i done.")
    end

    file = h5open("../data/traj$(filename).hdf5", "w")
    file["tx"] = tx
    writeattributes(file,p)
    close(file)

    println("Trajectory traj$(filename).hdf5 succesfully generated. See file in ../data")
end



#Executing the main function
#run(parameters)
