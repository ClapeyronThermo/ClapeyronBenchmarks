# ClapeyronBenchmarks

[![Benchmarks](https://github.com/ClapeyronThermo/ClapeyronBenchmarks/actions/workflows/Benchmarks.yml/badge.svg)](https://clapeyronthermo.github.io/ClapeyronBenchmarks/benchmarks/index.html)

Benchmark infrastructure and historical performance tracking for [Clapeyron.jl](https://github.com/ClapeyronThermo/Clapeyron.jl).

## Benchmark Systems and Model Coverage

| Benchmark system | Composition / components | Reference state | Models currently benchmarked |
| --- | --- | --- | --- |
| Common multicomponent mixture | water / methanol / ethanol / benzene, `z = [0.25, 0.25, 0.25, 0.25]` | `p = 1.0e5 Pa` | `PR`, `tcPR`, `VTPR`, `CPA`, `CKSAFT`, `SAFTVRMie`, `SAFTgammaMie`, `NRTL`, `UNIFAC`, `NRTL_PR` |
| GERG2008 gas mixture | methane / nitrogen / carbon dioxide / ethane, `z = [0.85, 0.05, 0.05, 0.05]` | `p = 5.0e6 Pa`, `T = 300.0 K` | `GERG2008` |
| Pure water | water, `z = [1.0]` | `p = 1.0e5 Pa` | `IAPWS95` |
| Electrolyte aqueous NaCl | water / sodium / chloride, `z = [0.9652224930507841, 0.0173887534746079, 0.0173887534746079]`, `m = [1.0] mol/kg` | `p = 1.0e5 Pa`, `T = 298.15 K` | `ePCSAFT` |

## First-Call Benchmark Coverage

| Benchmark item | Models covered | Notes |
| --- | --- | --- |
| Model construction | `PR`, `tcPR`, `VTPR`, `CPA`, `CKSAFT`, `SAFTVRMie`, `SAFTgammaMie`, `NRTL`, `UNIFAC`, `NRTL_PR`, `IAPWS95`, `GERG2008`, `ePCSAFT` | Measures cold-start initialization cost |
| `bubble_temperature/default` | `NRTL_PR` | Common multicomponent mixture |
| `dew_temperature/default` | `NRTL_PR` | Common multicomponent mixture |
| `bubble_pressure/ActivityBubblePressure` | `NRTL_PR` | Common multicomponent mixture |
| `dew_pressure/ActivityDewPressure` | `NRTL_PR` | Common multicomponent mixture |
| `tp_flash/default` | `NRTL_PR` | Common multicomponent mixture |

## Steady-State Benchmark Coverage

### By benchmark path

| Benchmark path | Variants | Common mixture | GERG2008 mixture | Pure water (`IAPWS95`) | Electrolyte (`ePCSAFT`) |
| --- | --- | --- | --- | --- | --- |
| `bubble_temperature` | `default` | `PR`, `tcPR`, `VTPR`, `CPA`, `CKSAFT`, `SAFTVRMie`, `SAFTgammaMie`, `NRTL`, `UNIFAC`, `NRTL_PR` | `GERG2008` | — | — |
| `dew_temperature` | `default` | `PR`, `tcPR`, `VTPR`, `CPA`, `CKSAFT`, `SAFTVRMie`, `SAFTgammaMie`, `NRTL`, `UNIFAC`, `NRTL_PR` | `GERG2008` | — | — |
| `tp_flash` | `default` | `PR`, `tcPR`, `VTPR`, `CPA`, `CKSAFT`, `SAFTVRMie`, `SAFTgammaMie`, `NRTL`, `UNIFAC`, `NRTL_PR` | `GERG2008` | — | — |
| `bubble_pressure` | `ActivityBubblePressure` | `NRTL`, `UNIFAC`, `NRTL_PR` | — | — | — |
| `dew_pressure` | `ActivityDewPressure` | `NRTL`, `UNIFAC`, `NRTL_PR` | — | — | — |
| `saturation_temperature` | `default` | — | — | `IAPWS95` | — |
| `saturation_pressure` | `default` | — | — | `IAPWS95` | — |
| `PH.temperature` | `two-phase`, `liquid-phase`, `vapour-phase` | `PR`, `tcPR`, `VTPR`, `CPA`, `CKSAFT`, `SAFTVRMie`, `SAFTgammaMie`, `NRTL`, `UNIFAC`, `NRTL_PR` | `GERG2008` | `IAPWS95` | — |
| `PH.entropy` | `two-phase`, `liquid-phase`, `vapour-phase` | `PR`, `tcPR`, `VTPR`, `CPA`, `CKSAFT`, `SAFTVRMie`, `SAFTgammaMie`, `NRTL`, `UNIFAC`, `NRTL_PR` | `GERG2008` | `IAPWS95` | — |
| `volume` | `liquid-phase`, `vapour-phase` | `PR`, `tcPR`, `VTPR`, `CPA`, `CKSAFT`, `SAFTVRMie`, `SAFTgammaMie`, `NRTL`, `UNIFAC`, `NRTL_PR` | `GERG2008` (`vapour-phase` only) | `IAPWS95` | `ePCSAFT` (`liquid-phase` only) |
| `enthalpy` | `liquid-phase`, `vapour-phase` | `PR`, `tcPR`, `VTPR`, `CPA`, `CKSAFT`, `SAFTVRMie`, `SAFTgammaMie`, `NRTL`, `UNIFAC`, `NRTL_PR` | — | `IAPWS95` | — |
| `isobaric_heat_capacity` | `liquid-phase`, `vapour-phase` | `PR`, `tcPR`, `VTPR`, `CPA`, `CKSAFT`, `SAFTVRMie`, `SAFTgammaMie`, `NRTL`, `UNIFAC`, `NRTL_PR` | — | — | — |
| `speed_of_sound` | `liquid-phase`, `vapour-phase` | — | `GERG2008` (`vapour-phase` only) | `IAPWS95` | — |
| `joule_thomson_coefficient` | `vapour-phase` | — | `GERG2008` | — | — |
| `mean_ionic_activity_coefficient` | `default` | — | — | — | `ePCSAFT` |
| `osmotic_coefficient` | `default` | — | — | — | `ePCSAFT` |
| `osmotic_coefficient_sat` | `default` | — | — | — | `ePCSAFT` |

### By source file

| Source file | Responsibility | Benchmark paths registered |
| --- | --- | --- |
| `benchmark/multiphase_properties.jl` | Initializes the steady-state benchmark group structure and registers multicomponent VLE benchmarks. | `bubble_temperature/default`, `dew_temperature/default`, `tp_flash/default`, `bubble_pressure/ActivityBubblePressure`, `dew_pressure/ActivityDewPressure` |
| `benchmark/bulk_properties.jl` | Registers PH and bulk-property benchmarks for common mixtures, pure fluids, and gas systems. | `PH.temperature/{two-phase, liquid-phase, vapour-phase}`, `PH.entropy/{two-phase, liquid-phase, vapour-phase}`, `volume/{liquid-phase, vapour-phase}`, `enthalpy/{liquid-phase, vapour-phase}`, `isobaric_heat_capacity/{liquid-phase, vapour-phase}`, `speed_of_sound/{liquid-phase, vapour-phase}`, `joule_thomson_coefficient/vapour-phase` |
| `benchmark/single_phase_properties.jl` | Registers pure-fluid saturation benchmarks. | `saturation_temperature/default`, `saturation_pressure/default` |
| `benchmark/electrolyte_properties.jl` | Registers electrolyte solution property benchmarks. | `volume/liquid-phase`, `mean_ionic_activity_coefficient/default`, `osmotic_coefficient/default`, `osmotic_coefficient_sat/default` |
