import ForwardDiff

function add_cosmosac_benchmarks!(Suite::BenchmarkGroup)
    property = "excess_gibbs_free_energy"
    model_name = "COSMOSAC10"
    components = ["water", "ethanol", "acetonitrile"]
    fluid_label = join(components, "/")
    model = guard_benchmark(benchmark_path("models", model_name, fluid_label)) do
        COSMOSAC10(components; puremodel=BasicIdeal())
    end
    isnothing(model) && return nothing

    # Differentiate with respect to T/300 and the three mole amounts.
    q = [313.15 / 300, 0.2, 0.3, 0.5]
    f(q) = Clapeyron.excess_gibbs_free_energy(model, 1.0e5, 300 * q[1], q[2:end])
    gcfg = ForwardDiff.GradientConfig(f, q)
    hcfg = ForwardDiff.HessianConfig(f, q)
    Suite[property] = BenchmarkGroup()
    for variant in ("default", "ForwardDiff.gradient", "ForwardDiff.hessian")
        Suite[property][variant] = BenchmarkGroup()
    end
    register_benchmark!(Suite[property]["default"], model_name, fluid_label,
        benchmark_path(property, "default", model_name, fluid_label),
        () -> f(q), () -> @benchmarkable $f($q))
    register_benchmark!(Suite[property]["ForwardDiff.gradient"], model_name, fluid_label,
        benchmark_path(property, "ForwardDiff.gradient", model_name, fluid_label),
        () -> ForwardDiff.gradient(f, q, gcfg),
        () -> @benchmarkable ForwardDiff.gradient($f, $q, $gcfg))
    register_benchmark!(Suite[property]["ForwardDiff.hessian"], model_name, fluid_label,
        benchmark_path(property, "ForwardDiff.hessian", model_name, fluid_label),
        () -> ForwardDiff.hessian(f, q, hcfg),
        () -> @benchmarkable ForwardDiff.hessian($f, $q, $hcfg))
    nothing
end
