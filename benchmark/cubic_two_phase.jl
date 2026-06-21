const Cubic_Models = (PR, cPR, SRK, RK, KU)

"""
benchmarking two phase falsh computations for cubic eos
"""
function cubic_ph_flash(Suite::BenchmarkGroup)
    fluids = ["pentane", "isopentane"] # High glide
    p0 = 101325
    z0 = [1.0, 1.0]
    Suite["PH_FLASH"] = BenchmarkGroup()

    T_dew(model) = dew_temperature(model, p0, z0)[1]
    T_bub(model) = bubble_temperature(model, p0, z0)[1]

    for eos_constructor in Cubic_Models
        eos_name = string(eos_constructor)
        fluid_label = join(fluids, "/")

        m_ = nothing
        first_s = @elapsed m_ = eos_constructor(fluids; idealmodel=ReidIdeal)
        push!(first_results, first_metric_row([eos_name, "ReidIdeal", eos_name, fluid_label], first_s, "s"))

        Tb = T_bub(m_)
        Td = T_dew(m_)
        hb = enthalpy(m_, p0, Tb, z0)
        hd = enthalpy(m_, p0, Td, z0)
        h_ = (hb+hd)/2

        first_s = @elapsed Clapeyron.PH.temperature(m_, p0, h_, z0)
        push!(first_results, first_metric_row(["PH.temperature", "default", eos_name, fluid_label], first_s, "s"))

        first_s = @elapsed Clapeyron.PH.entropy(m_, p0, h_, z0)
        push!(first_results, first_metric_row(["PH.entropy", "default", eos_name, fluid_label], first_s, "s"))

        Suite["PH.temperature"] = BenchmarkGroup()
        Suite["PH.temperature"]["default"] = BenchmarkGroup()
        Suite["PH.temperature"]["default"][eos_name] = BenchmarkGroup()
        Suite["PH.temperature"]["default"][eos_name]["pentane/isopentane"] = @benchmarkable Clapeyron.PH.temperature($m_, $p0, $h_, $z0)

        Suite["PH.entropy"] = BenchmarkGroup()
        Suite["PH.entropy"]["default"] = BenchmarkGroup()
        Suite["PH.entropy"]["default"][eos_name] = BenchmarkGroup()
        Suite["PH.entropy"]["default"][eos_name]["pentane/isopentane"] = @benchmarkable Clapeyron.PH.entropy($m_, $p0, $h_, $z0)

        hv = enthalpy(m_, p0, Td + 10, z0)
        hl = enthalpy(m_, p0, Tb - 10, z0)

        first_s = @elapsed Clapeyron.PH.temperature(m_, p0, hl, z0)
        push!(first_results, first_metric_row(["PH.temperature", "default", eos_name, fluid_label], first_s, "s"))

        first_s = @elapsed Clapeyron.PH.temperature(m_, p0, hv, z0)
        push!(first_results, first_metric_row(["PH.temperature", "default", eos_name, fluid_label], first_s, "s"))

        first_s = @elapsed Clapeyron.PH.entropy(m_, p0, hl, z0)
        push!(first_results, first_metric_row(["PH.entropy", "default", eos_name, fluid_label], first_s, "s"))

        first_s = @elapsed Clapeyron.PH.entropy(m_, p0, hv, z0)
        push!(first_results, first_metric_row(["PH.entropy", "default", eos_name, fluid_label], first_s, "s"))

        Suite["PH.temperature"]["default"] = BenchmarkGroup()
        Suite["PH.temperature"]["default"][eos_name] = BenchmarkGroup()
        Suite["PH.temperature"]["default"][eos_name]["pentane/isopentane"] = @benchmarkable Clapeyron.PH.temperature($m_, $p0, $hl, $z0)

        Suite["PH.temperature"]["default"] = BenchmarkGroup()
        Suite["PH.temperature"]["default"][eos_name] = BenchmarkGroup()
        Suite["PH.temperature"]["default"][eos_name]["pentane/isopentane"] = @benchmarkable Clapeyron.PH.temperature($m_, $p0, $hv, $z0)

        Suite["PH.entropy"]["default"] = BenchmarkGroup()
        Suite["PH.entropy"]["default"][eos_name] = BenchmarkGroup()
        Suite["PH.entropy"]["default"][eos_name]["pentane/isopentane"] = @benchmarkable Clapeyron.PH.entropy($m_, $p0, $hl, $z0)

        Suite["PH.entropy"]["default"] = BenchmarkGroup()
        Suite["PH.entropy"]["default"][eos_name] = BenchmarkGroup()
        Suite["PH.entropy"]["default"][eos_name]["pentane/isopentane"] = @benchmarkable Clapeyron.PH.entropy($m_, $p0, $hv, $z0)
    end
end

if pkgversion(Clapeyron) >= v"0.6.8"
    cubic_ph_flash(Suite)
end
