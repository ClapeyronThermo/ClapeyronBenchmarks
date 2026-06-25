# Benchmark Group Protocol:
# Function + Secondary param + Property method + specific materials

# PR,           Cubic EOS: baseline model for conventional cubic-equation performance
# tcPR,         Translated-consistent cubic EOS: modern volume translation and improved thermodynamic consistency
# VTPR,         Predictive cubic EOS: advanced mixing rule coupled with UNIFAC group-contribution terms
# CPA,          Cubic-association EOS: coupling between a cubic reference term and molecular association
# PCSAFT,       SAFT EOS: representative industrial chain-based statistical associating fluid theory model
# SAFTVRMie,    Mie-based SAFT EOS: variable-range intermolecular potential and more complex perturbation terms
# SAFTgammaMie, Group-contribution SAFT EOS: heterogeneous molecular groups combined with a Mie potential
# NRTL,         Activity-coefficient model: representative component-based local-composition model
# NRTL_PR,      Gamma-phi composite model: NRTL liquid phase coupled with a PR vapor-phase EOS
# UNIFAC,       Group-contribution activity model: functional-group decomposition and group-interaction calculations
# IAPWS95,      Pure-fluid multiparameter Helmholtz EOS: high-accuracy derivatives and critical-region terms
# GERG2008,     Mixture multiparameter Helmholtz EOS: multifluid mixing, reducing functions, and departure terms
# ePCSAFT,      Electrolyte EOS: neutral-fluid PC-SAFT contributions combined with ionic interactions

const BenchmarkSystems = (
    common=(
        components=["water", "methanol", "ethanol", "benzene"],
        saftgammamie_components=[("water", ["H2O"=>1]), ("methanol", ["CH3OH"=>1]), ("ethanol", ["CH2OH"=>1, "CH3"=>1]), ("benzene", ["aCH"=>6])],
        z=[0.25, 0.25, 0.25, 0.25],
        p=1.0e5,  # Pa
        models=(PR, tcPR, VTPR, CPA, CKSAFT, SAFTVRMie, SAFTgammaMie, NRTL, UNIFAC), # +NRTL_PR
    ),
    iapws95=(
        components=["water"],
        z=[1.0],
        p=1.0e5,  # Pa
        models=(IAPWS95,),
    ),
    gerg2008=(
        components=["methane", "nitrogen", "carbon dioxide", "ethane"],
        z=[0.85, 0.05, 0.05, 0.05],
        p=5.0e6,  # Pa
        T=300.0,  # K
        models=(GERG2008,),
    ),
    epcsaft=(
        solvents=["water"],
        ions=["sodium", "chloride"],
        z=[0.9652224930507841, 0.0173887534746079, 0.0173887534746079],
        p=1.0e5,  # Pa
        T=298.15, # K
        m=[1.0],  # mol/kg
        models=(ePCSAFT,),
    ),
)

function first_metric_row(path::Vector{String}, value::Real, unit::String)
    return (
        benchmark_path=path,
        metric_name="time",
        statistic="first",
        unit=unit,
        value=Float64(value),
        better="lower",
    )
end
