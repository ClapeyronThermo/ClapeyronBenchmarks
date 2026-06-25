function add_pure_saturation_benchmarks!(Suite::BenchmarkGroup, model_name, model, p, fluid_label)
    Tsat = saturation_temperature(model, p)[1]

    Suite["saturation_temperature"]["default"][model_name] = BenchmarkGroup()
    Suite["saturation_temperature"]["default"][model_name][fluid_label] = @benchmarkable saturation_temperature($model, $p)

    Suite["saturation_pressure"]["default"][model_name] = BenchmarkGroup()
    Suite["saturation_pressure"]["default"][model_name][fluid_label] = @benchmarkable saturation_pressure($model, $Tsat)
    nothing
end
