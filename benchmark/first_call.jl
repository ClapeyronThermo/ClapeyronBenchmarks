function first_call_benchmarks()
    first_results = NamedTuple[]

    common = BenchmarkSystems.common
    common_label = join(common.components, "/")

    vap_pr = push_first_call!(first_results, benchmark_path("PR", "BasicIdeal", "PR", common_label)) do
        PR(common.components)
    end

    m_tcpr = push_first_call!(first_results, benchmark_path("tcPR", "BasicIdeal", "tcPR", common_label)) do
        tcPR(common.components)
    end

    m_vtpr = push_first_call!(first_results, benchmark_path("VTPR", "BasicIdeal", "VTPR", common_label)) do
        VTPR(common.components)
    end

    m_cpa = push_first_call!(first_results, benchmark_path("CPA", "BasicIdeal", "CPA", common_label)) do
        CPA(common.components; assoc_options=AssocOptions(combining=:esd))
    end

    m_cksaft = push_first_call!(first_results, benchmark_path("CKSAFT", "BasicIdeal", "CKSAFT", common_label)) do
        CKSAFT(common.components)
    end

    m_saftvrmie = push_first_call!(first_results, benchmark_path("SAFTVRMie", "BasicIdeal", "SAFTVRMie", common_label)) do
        SAFTVRMie(common.components)
    end

    m_saftgammamie = push_first_call!(first_results, benchmark_path("SAFTgammaMie", "BasicIdeal", "SAFTgammaMie", common_label)) do
        SAFTgammaMie(common.saftgammamie_components)
    end

    liq_nrtl = push_first_call!(first_results, benchmark_path("NRTL", "BasicIdeal", "NRTL", common_label)) do
        NRTL(common.components; puremodel=BasicIdeal)
    end

    liq_unifac = push_first_call!(first_results, benchmark_path("UNIFAC", "BasicIdeal", "UNIFAC", common_label)) do
        UNIFAC(common.components; puremodel=BasicIdeal)
    end

    m_nrtl_pr = push_first_call!(first_results, benchmark_path("NRTL_PR", "BasicIdeal/BasicIdeal", "NRTL_PR", common_label)) do
        CompositeModel(common.components; liquid=liq_nrtl, fluid=vap_pr)
    end

    iapws95 = BenchmarkSystems.iapws95
    iapws95_label = join(iapws95.components, "/")

    m_iapws95 = push_first_call!(first_results, benchmark_path("IAPWS95", "default", "IAPWS95", iapws95_label)) do
        IAPWS95()
    end

    gerg2008 = BenchmarkSystems.gerg2008
    gerg2008_label = join(gerg2008.components, "/")

    m_gerg2008 = push_first_call!(first_results, benchmark_path("GERG2008", "default", "GERG2008", gerg2008_label)) do
        GERG2008(gerg2008.components)
    end

    epcsaft = BenchmarkSystems.epcsaft
    epcsaft_label = join([epcsaft.solvents; epcsaft.ions], "/")

    m_epcsaft = push_first_call!(first_results, benchmark_path("ePCSAFT", "BasicIdeal/pharmaPCSAFT/hsdDH/ConstRSP", "ePCSAFT", epcsaft_label)) do
        ePCSAFT(epcsaft.solvents, epcsaft.ions)
    end

    if !isnothing(m_nrtl_pr)
        Tb_pr = push_first_call!(first_results, benchmark_path("bubble_temperature", "default", "NRTL_PR", common_label)) do
            bubble_temperature(m_nrtl_pr, common.p, common.z)[1]
        end

        Td_pr = push_first_call!(first_results, benchmark_path("dew_temperature", "default", "NRTL_PR", common_label)) do
            dew_temperature(m_nrtl_pr, common.p, common.z)[1]
        end

        if !isnothing(Tb_pr) && !isnothing(Td_pr)
            T_pr = (Tb_pr + Td_pr) / 2

            pb_nrtl_pr = push_first_call!(first_results, benchmark_path("bubble_pressure", "ActivityBubblePressure", "NRTL_PR", common_label)) do
                bubble_pressure(m_nrtl_pr, T_pr, common.z, ActivityBubblePressure())[1]
            end

            pd_nrtl_pr = push_first_call!(first_results, benchmark_path("dew_pressure", "ActivityDewPressure", "NRTL_PR", common_label)) do
                dew_pressure(m_nrtl_pr, T_pr, common.z, ActivityDewPressure())[1]
            end

            if !isnothing(pb_nrtl_pr) && !isnothing(pd_nrtl_pr)
                pf_nrtl_pr = √(pb_nrtl_pr * pd_nrtl_pr)

                push_first_call!(first_results, benchmark_path("tp_flash", "default", "NRTL_PR", common_label)) do
                    tp_flash(m_nrtl_pr, pf_nrtl_pr, T_pr, common.z)
                end
            end
        end
    end

    return first_results
end
