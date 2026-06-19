


"""
benchmarking two phase falsh computations for cubic eos
"""
function benchmark_cubic_two_phase(SUITE::BenchmarkGroup)
    cubics = [cPR, SRK, KU] 
    fluids = ["pentane", "isopentane"] # High glide
    p0 = 101325
    z0 = [1.0, 1.0]
    SUITE["two_phase_computation"] = BenchmarkGroup()

    T_dew(model) = dew_temperature(model, p0, z0)[1]
    T_bub(model) = bubble_temperature(model, p0, z0)[1]

    for eos_constructor in cubics

        m_ = eos_constructor(fluids; idealmodel = ReidIdeal)

        Tb = T_bub(m_)
        Td = T_dew(m_)

        hb = enthalpy(m_, p0, Tb, z0)
        hd = enthalpy(m_, p0, Td, z0)

        h_ = (hb+hd)/2
        eos_name = string(eos_constructor)

        SUITE["two_phase_computation"][eos_name] = BenchmarkGroup()
        grp = SUITE["two_phase_computation"][eos_name]
        grp["pentane/isopentane"] = BenchmarkGroup()
        grp["pentane/isopentane"]["PH-Flash"] = BenchmarkGroup()

        grp["pentane/isopentane"]["PH-Flash"]["temperature"] = @benchmarkable begin
            try
                Clapeyron.PH.temperature($m_, $p0,$h_, $z0)
            catch
                nothing
            end
        end
        grp["pentane/isopentane"]["PH-Flash"]["entropy"] = @benchmarkable begin
            try
                Clapeyron.PH.entropy($m_, $p0,$h_, $z0)
            catch
                nothing
            end
        end


    end
end


benchmark_cubic_two_phase(SUITE)