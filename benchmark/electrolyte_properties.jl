function add_electrolyte_benchmarks!(Suite::BenchmarkGroup, model_name, model, p, T, z, m, fluid_label)
    Suite["volume"]["liquid-phase"][model_name] = BenchmarkGroup()
    Suite["volume"]["liquid-phase"][model_name][fluid_label] = @benchmarkable volume($model, $p, $T, $z; phase=:l)

    Suite["mean_ionic_activity_coefficient"]["default"][model_name] = BenchmarkGroup()
    Suite["mean_ionic_activity_coefficient"]["default"][model_name][fluid_label] = @benchmarkable mean_ionic_activity_coefficient($model, $p, $T, $m)

    Suite["osmotic_coefficient"]["default"][model_name] = BenchmarkGroup()
    Suite["osmotic_coefficient"]["default"][model_name][fluid_label] = @benchmarkable osmotic_coefficient($model, $p, $T, $m)

    Suite["osmotic_coefficient_sat"]["default"][model_name] = BenchmarkGroup()
    Suite["osmotic_coefficient_sat"]["default"][model_name][fluid_label] = @benchmarkable osmotic_coefficient_sat($model, $T, $m)
    nothing
end
