# ClapeyronBenchmarks

[![Benchmarks](https://github.com/ClapeyronThermo/ClapeyronBenchmarks/actions/workflows/Benchmarks.yml/badge.svg)](https://clapeyronthermo.github.io/ClapeyronBenchmarks/benchmarks/index.html)

Benchmark infrastructure and historical performance tracking for [Clapeyron.jl](https://github.com/ClapeyronThermo/Clapeyron.jl).

## Benchmark Systems and Model Coverage

| Benchmark system | Composition / components | Reference state | Tested models |
| --- | --- | --- | --- |
| Common multicomponent mixture | water / methanol / ethanol / benzene, `z = [0.25, 0.25, 0.25, 0.25]` | `p = 1.0e5 Pa` | PR, tcPR, VTPR, CPA, CKSAFT, SAFTVRMie, SAFTgammaMie, NRTL, UNIFAC, NRTL_PR |
| GERG2008 gas mixture | methane / nitrogen / carbon dioxide / ethane, `z = [0.85, 0.05, 0.05, 0.05]` | `p = 5.0e6 Pa`, `T = 300.0 K` | GERG2008 |
| Pure water | water, `z = [1.0]` | `p = 1.0e5 Pa` | IAPWS95 |
| Electrolyte aqueous NaCl | water / sodium / chloride, `z = [0.9652224930507841, 0.0173887534746079, 0.0173887534746079]`, `m = [1.0] mol/kg` | `p = 1.0e5 Pa`, `T = 298.15 K` | ePCSAFT |

## First-Call Benchmark Coverage

| Function under test  | Variants | Tested models |
| -------------------- | -------- | ------------- |
| Model construction   | —                        | PR, tcPR, VTPR, CPA, CKSAFT, SAFTVRMie, SAFTgammaMie, NRTL, UNIFAC, NRTL_PR, IAPWS95, GERG2008, ePCSAFT |
| `bubble_temperature` | `default`                | NRTL_PR |
| `dew_temperature`    | `default`                | NRTL_PR |
| `bubble_pressure`    | `ActivityBubblePressure` | NRTL_PR |
| `dew_pressure`       | `ActivityDewPressure`    | NRTL_PR |
| `tp_flash`           | `default`                | NRTL_PR |

## Steady-State Benchmark Coverage

### By function under test

| Function under test               | Variants                                    | Tested models                                                                                                                                           |
| --------------------------------- | ------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `bubble_temperature`              | `default`                                   | PR, tcPR, VTPR, CPA, CKSAFT, SAFTVRMie, SAFTgammaMie, NRTL, UNIFAC, NRTL_PR, GERG2008                                                                   |
| `dew_temperature`                 | `default`                                   | PR, tcPR, VTPR, CPA, CKSAFT, SAFTVRMie, SAFTgammaMie, NRTL, UNIFAC, NRTL_PR, GERG2008                                                                   |
| `tp_flash`                        | `default`                                   | PR, tcPR, VTPR, CPA, CKSAFT, SAFTVRMie, SAFTgammaMie, NRTL, UNIFAC, NRTL_PR, GERG2008                                                                   |
| `bubble_pressure`                 | `ActivityBubblePressure`                    | NRTL, UNIFAC, NRTL_PR                                                                                                                                   |
| `dew_pressure`                    | `ActivityDewPressure`                       | NRTL, UNIFAC, NRTL_PR                                                                                                                                   |
| `saturation_temperature`          | `default`                                   | IAPWS95                                                                                                                                                 |
| `saturation_pressure`             | `default`                                   | IAPWS95                                                                                                                                                 |
| `PH.temperature`                  | `two-phase`, `liquid-phase`, `vapour-phase` | PR, tcPR, VTPR, CPA, CKSAFT, SAFTVRMie, SAFTgammaMie, NRTL, UNIFAC, NRTL_PR, GERG2008, IAPWS95                                                          |
| `PH.entropy`                      | `two-phase`, `liquid-phase`, `vapour-phase` | PR, tcPR, VTPR, CPA, CKSAFT, SAFTVRMie, SAFTgammaMie, NRTL, UNIFAC, NRTL_PR, GERG2008, IAPWS95                                                          |
| `volume`                          | `liquid-phase`, `vapour-phase`              | PR, tcPR, VTPR, CPA, CKSAFT, SAFTVRMie, SAFTgammaMie, NRTL, UNIFAC, NRTL_PR, IAPWS95; GERG2008 (vapour-phase); ePCSAFT (liquid-phase) |
| `enthalpy`                        | `liquid-phase`, `vapour-phase`              | PR, tcPR, VTPR, CPA, CKSAFT, SAFTVRMie, SAFTgammaMie, NRTL, UNIFAC, NRTL_PR, IAPWS95                                                                    |
| `isobaric_heat_capacity`          | `liquid-phase`, `vapour-phase`              | PR, tcPR, VTPR, CPA, CKSAFT, SAFTVRMie, SAFTgammaMie, NRTL, UNIFAC, NRTL_PR                                                                             |
| `speed_of_sound`                  | `liquid-phase`, `vapour-phase`              | IAPWS95; GERG2008 (vapour-phase)       |
| `joule_thomson_coefficient`       | `vapour-phase`                              | GERG2008                                                                                                                                                |
| `mean_ionic_activity_coefficient` | `default`                                   | ePCSAFT                                                                                                                                                 |
| `osmotic_coefficient`             | `default`                                   | ePCSAFT                                                                                                                                                 |
| `osmotic_coefficient_sat`         | `default`                                   | ePCSAFT                                                                                                                                                 |

### By source file

| Source file                            | Functions registered  |
| -------------------------------------- | --------------------- |
| `benchmark/multiphase_properties.jl`   | `bubble_temperature/default`<br>`dew_temperature/default`<br>`tp_flash/default`<br>`bubble_pressure/ActivityBubblePressure`<br>`dew_pressure/ActivityDewPressure` |
| `benchmark/bulk_properties.jl`         | `PH.temperature/two-phase`<br>`PH.temperature/liquid-phase`<br>`PH.temperature/vapour-phase`<br>`PH.entropy/two-phase`<br>`PH.entropy/liquid-phase`<br>`PH.entropy/vapour-phase`<br>`volume/liquid-phase`<br>`volume/vapour-phase`<br>`enthalpy/liquid-phase`<br>`enthalpy/vapour-phase`<br>`isobaric_heat_capacity/liquid-phase`<br>`isobaric_heat_capacity/vapour-phase`<br>`speed_of_sound/liquid-phase`<br>`speed_of_sound/vapour-phase`<br>`joule_thomson_coefficient/vapour-phase` |
| `benchmark/single_phase_properties.jl` | `saturation_temperature/default`<br>`saturation_pressure/default` |
| `benchmark/electrolyte_properties.jl`  | `volume/liquid-phase`<br>`mean_ionic_activity_coefficient/default`<br>`osmotic_coefficient/default`<br>`osmotic_coefficient_sat/default` |
