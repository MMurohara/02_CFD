---
documentclass: ltjsarticle
header-includes:
  - \usepackage[margin=1in]{geometry} 
  - \usepackage[version=3]{mhchem}
  - \setkeys{Gin}{width=8cm}

title: |
  Polyblock AG社とのFormFlex HXに関する研究開発について
author: |
  Masaya MUROHARA
titlepage: true
titlepage-color: "FFFFFF"

bibliography: refs.bib
csl: acta-astronautica.csl

figureTitle: "Fig. "
tableTitle: "Table "
listingTitle: "Code "
figPrefix: "Fig."
eqnPrefix: "Eq."
tblPrefix: "Table "
lstPrefix: "Code "
---

# Theory

## Exchange effectiveness

Sensible heat is defined by the temperature exchange effectiveness, and latent heat is defined by the humidity exchange effectiveness. Each flow is defined as shown in [@fig:POL_flow_schematics]. The abbreviations are as follows.

* OA: Outer Air. Air sent from outdoors to the total heat exchanger
* SA: Supply Air. Air supplied indoors after passing through the total heat exchanger
* RA: Return Air. Air sent from indoors to the total heat exchanger
* EA: Exhausted Air. Air discharged outdoors after passing through the total heat exchanger

![Shematic of a enthalpy exchanger element (corrugate/ cross flow) .](img/POL_flow_schematics.png){#fig:POL_flow_schematics}

If temperature is represented by $T$ and humidity by $\omega$, the corresponding exchange effectiveness values $\eta_{\mathrm{t}}$ and $\eta_{\mathrm{h}}$ can be expressed as follows.

$$
\eta_{\mathrm{T}} = \frac{T_{\mathrm{OA}} - T_{\mathrm{SA}}}
{T_{\mathrm{OA}} - T_{\mathrm{RA}}}
$${#eq:temperature_exchange_eff}

$$
\eta_{\mathrm{\omega}} = \frac{\omega_{\mathrm{OA}} - \omega_{\mathrm{SA}}}
{\omega_{\mathrm{OA}} - \omega_{\mathrm{RA}}}
$${#eq:humid_exchange_eff}

## Representation of moisture flux using $\omega$

The most important aspect of this analysis is the modeling of moisture transport through the membrane. The model described below was developed by J.L. Niu and L.Z. Zhang in 2001 [@Niu2001-es] and has continued to be used up to the latest paper in 2025 [@Liu2025-mz]. In this model, three representations of moisture appear: the absolute humidity in air $\omega$, the relative humidity in air $\phi$, and the absolute humidity in the membrane $\theta$. Their definitions are as follows.

$$
\omega = \frac{m_{\mathrm{vapor}}}{m_{\mathrm{dry , air}}}
$${#eq:def_omega}

$$
\phi = \frac{p_{\mathrm{vapor}}}{p_{\mathrm{sat}}}
$${#eq:def_phi}

$$
\theta = \frac{m_{\mathrm{vapor}}}{m_{\mathrm{dry , membrane}}}
$${#eq:def_theta}

Here, $m$ denotes mass and $p$ denotes pressure. In Fluent, the mass fraction $Y$ of each constituent species is generally used. That is,

$$
Y_{\mathrm{vapor}} = \frac{m_{\mathrm{vapor}}}{m_{\mathrm{dry , air}} + m_{\mathrm{vapor}}}
$${#eq:def_Y}
For simplicity, the subscripts vapor, membrane, and air are hereafter denoted as v, m, and a, respectively. The absolute humidity $\omega$ and relative humidity $\phi$ in air, and the absolute humidity $\omega$ and mass fraction $Y$, can be converted using the following equations.

$$
p_{\mathrm{v}} = \frac{\omega p_{\mathrm{tot}}}{\omega + 0.622}
$${#eq:p_to_omega}

$$
\begin{aligned}
\frac{\phi}{\omega} &= A - 1.61\phi \\
&\approx  A\\
A &= \exp \left( 5294/T\right) \times 10^{-6}
\end{aligned}
$${#eq:phi_to_omega}

$$
\omega = \frac{Y_{\mathrm{v}}}{1-Y_{\mathrm{v}}}
$${#eq:omega_to_Y}

Here, the second term in Eq. [@eq:phi_to_omega] is 5% or less and is generally neglected [@Niu2001-es].
So far, four representations of moisture have appeared. In the field of total heat exchange, it is common practice to use $\omega$. On the other hand, in numerical analysis, $Y$ is often used. As of 2013, there is a statement that “moisture transfer in porous media cannot be calculated well. Therefore, each researcher develops their own code or runs Fluent using UDFs” [@Al-Waked2013-nv]. Since moisture transport in the fluid region of a porous medium in Fluent, namely simple advection-diffusion of water vapor, appears to have already been supported as a standard function at that time, this statement is considered to refer to the treatment of water vapor that is adsorbed and diffuses in the solid part of the porous material. In [@Liu2025-mz] as well, it is stated that even in version 2024R1, the mass transfer model inside the membrane is not handled, and a UDF was used. Therefore, in this chapter, the modeling is first carried out using the $\omega$ representation, and then it is converted into a form using $Y$ in order to make it compatible with Fluent.
The following assumptions are made for the modeling.

1. Moisture transport in the in-plane flow direction is neglected. This is based on the calculation results in reference [@Niu2001-es]. Since this assumption may break down depending on the operating conditions, it should be confirmed that the Pe number is 2 or larger.

2. Moisture absorption in the membrane is in equilibrium.

3. The moisture diffusion coefficient in the membrane $D_{\mathrm{m}}$ is constant.

4. The heat absorption and heat release during moisture absorption and desorption are constant and have the same value.

First, since moisture absorption in the membrane is in equilibrium, the flux from the supply-side air to the membrane $j_{\mathrm{s}}$, the flux inside the membrane $j_{\mathrm{m}}$, and the flux from the membrane to the exhaust-side air $j_{\mathrm{e}}$ are equal. That is,

$$
j_{\mathrm{s}} = j_{\mathrm{m}} = j_{\mathrm{e}}
$${#eq:flux_equ}

Here, the unit of flux is $[\mathrm{kg ; m^{-2} ; s^{-1}}]$. The moisture fluxes in air, $j_{\mathrm{s}}$ and $j_{\mathrm{e}}$, are expressed by Fick’s law regardless of whether they are on the intake side or the exhaust side. That is,

$$
j_{\mathrm{s}} =j_{\mathrm{e}} = - \rho_{\mathrm{a}} D_{\mathrm{a}} \frac{\partial \omega}{\partial z}
$${#eq:fick_law}

Here, $D$ is the diffusion coefficient with respect to $\omega$ [$\mathrm{m^2 ; s^{-1}}$], and it should be noted that it takes a different value when converted to $Y$, as described later.
Next, consider the flux inside the membrane $j_{\mathrm{m}}$. To do this, it is necessary to obtain the relationship between $\omega$ in the air near the membrane and $\theta$ at the membrane surface. This $\theta$ strongly depends on the membrane material properties and humidity, and must be determined experimentally. For example, an analyzer such as a Vapor absorption analyzer - Hydrosorb-1000 [@Zhang2008-sa] can be used. Through this analysis, a sorption curve is obtained. The sorption curve takes the relative humidity $\phi$ on the horizontal axis and the absolute humidity of the membrane $\theta$ on the vertical axis, and is expressed by the following equation.

$$
\theta = \frac{w_{\mathrm{max}}}
{1-C+C/\phi}
$${#eq:sorption_curve}

Here, $w_{\mathrm{max}}$ is $\theta$ when $\phi$ is 100%. $C$ is a variable that mainly represents the type of membrane or hygroscopic material. For example, the most commonly used silica gel has $C \approx 1$, whereas polymer materials show values of approximately $C \approx 10$. Sorption curves for each value of $C$ are shown in [@fig:POL_sorption_curve].

![Sorption curves with representative $C$ numbers.](img/POL_sorption_curve.png){#fig:POL_sorption_curve}

By experimentally determining this sorption curve, $\theta$ at the membrane surface is obtained. When this moisture diffuses through the membrane, if the diffusion coefficient of the membrane is denoted by $D_{\mathrm{m}} ; [\mathrm{m^2 ; s^{-1}}]$, the moisture flux inside the membrane is expressed as

$$
j_{\mathrm{m}} = - \rho_{\mathrm{m}} D_{\mathrm{m}}\frac{\partial \theta}{\partial z}
$${#eq:vapor_flux_in_membrane}

For example, the diffusion coefficient of paper is approximately $6 \times 10^{-12} ; \mathrm{m^2 ; s^{-1}}$. Since this equation is written in terms of $\theta$, it must be converted to $\omega$. For this conversion, the membrane resistance $r_{\mathrm{m}}$, which also accounts for the membrane thickness, is expressed as

$$
r_{\mathrm{m}} =\frac{\rho_{\mathrm{a}}}{\rho_{\mathrm{m}}} \frac{\delta}{D_{\mathrm{m}}} \psi
$${#eq:moisture_resistance}

$$
\psi = \left(A\frac{\partial \theta}{\partial \phi} \right)^{-1}
$${#eq:CMDR}

Here, the values of $A$ and $\phi$ on the supply-air side are used. The product $\rho_{\mathrm{m}}D_{\mathrm{m}}$ is sometimes treated collectively as the moisture permeability coefficient $K [\mathrm{kg ; m^{-1} ; s^{-1}}]$. See reference [@Niu2001-es] for details. Here, $\psi$ is called the coefficient of moisture diffusive resistance. Using Eq. [@eq:phi_to_omega], this CMDR can be transformed as

$$
\begin{aligned}
\psi &= \left(A\frac{\partial \theta}{\partial \phi} \right)^{-1} \
&=  \left( A \frac{\partial \theta}{\partial \omega} \frac{\partial \omega}{\partial \phi} \right) ^{-1} \
&= \left( \frac{\partial \theta}{\partial \omega} \right)^{-1}
\end{aligned}
$${#eq:CMDR_rev}

Therefore, using Eqs. [@eq:vapor_flux_in_membrane], [@eq:moisture_resistance], and [@eq:CMDR_rev], the moisture flux inside the membrane becomes

$$
j_{\mathrm{m}} = -\frac{\rho_{\mathrm{a}} \delta }{r_{\mathrm{m}}}\frac{\partial \omega}{\partial z}
$${#eq:vapor_flux_in_membrane_rev}
Thus, [@eq:flux_equ], [@eq:fick_law], and [@eq:vapor_flux_in_membrane_rev] express all moisture fluxes: from the supply-side air to the membrane, from the inside of the membrane to the outside of the membrane, and from the membrane to the exhaust-side air.

By discretizing and solving [@eq:flux_equ], $\omega_{\mathrm{m}}$ can be expressed only in terms of the air-side $\omega_{\mathrm{a}}$. For the discretization, the following subscripts are defined.

* as: air at supply flow

* ms: membrane surface at supply side

* me: membrane surface at exhaust side

* ae: air at exhaust flow
  Also, let the distance from the membrane surface to the center of the adjacent space cell be $\Delta z$, and let the membrane thickness be $\delta$. Then,

$$
j_{\mathrm{s}} = - \rho_{\mathrm{as}} D_{\mathrm{as}}
\frac{\omega_{\mathrm{ms}}-\omega_{\mathrm{as}}}{\Delta z_{\mathrm{s}}}
$${#eq:diff_flux_supply}

$$
j_{\mathrm{m}} = - \frac{\rho_{\mathrm{as}} \delta }{r_{\mathrm{m}}}
\frac{\omega_{\mathrm{me}}-\omega_{\mathrm{ms}}}{\delta}
$${#eq:diff_flux_membrane}

$$
j_{\mathrm{e}} = - \rho_{\mathrm{ae}} D_{\mathrm{ae}}
\frac{\omega_{\mathrm{ae}}-\omega_{\mathrm{me}}}{\Delta z_{\mathrm{e}}}
$${#eq:diff_flux_exhaust}

Solving $j_{\mathrm{s}} + j_{\mathrm{e}} = 0$ and $j_{\mathrm{s}} + j_{\mathrm{m}} = 0$ gives

$$
\omega_{\mathrm{me}} = \omega_{\mathrm{ae}} + \alpha \left(
\omega_{\mathrm{as}} - \omega_{\mathrm{ms}}
\right)\
\alpha = \frac{\rho_{\mathrm{as}}}{\rho_{\mathrm{ae}}} \frac{D_{\mathrm{as}}}{D_{\mathrm{ae}}} \frac{\Delta z_{\mathrm{ae}}}{\Delta z_{\mathrm{as}}}
$${#eq:omega_me}

and

$$
\omega_{\mathrm{ms}} =\frac{
\beta \omega_{\mathrm{ae}} + (\alpha \beta  + 1)\omega_{\mathrm{as}}
}{
\beta + \alpha \beta + 1
}\
\beta = \frac{\rho_{\mathrm{m}}}{\rho_{\mathrm{as}}} \frac{D_{\mathrm{m}}}{D_{\mathrm{as}}} \frac{\Delta z_{\mathrm{as}}}{\delta} \frac{1}{\psi}
$${#eq:omega_ms}

These two equations allow $\omega$ at each membrane surface to be expressed in terms of the air-side $\omega$.

### Representation of moisture flux using $Y$

Among the variables introduced so far, the quantities that can be treated as constant physical properties are the densities $\rho$ and the diffusion coefficients $D$. Among these, the diffusion coefficient data held in Fluent are based on the mass-fraction gradient. Up to this point, Fick’s law has been expressed using $\omega$ in accordance with the convention in the field of heat exchangers. Rewriting it into a form compatible with Fluent gives

$$
\begin{aligned}
j &= - \rho D \frac{\partial \omega}{\partial z}\
&= - \rho D \frac{\partial Y}{\partial z} \frac{\partial \omega}{\partial Y}\
&= - \rho \frac{D}{(1-Y)^2} \frac{\partial Y}{\partial z}
\end{aligned}
$${#eq:fick_law_in_Y}
Thus, if the diffusion coefficient based on $Y$ is denoted by $D'$, using $D' = D / (1-Y)^2$ gives

$$
\begin{aligned}
j = - \rho D' \frac{\partial Y}{\partial z}
\end{aligned}
$${#eq:fick_law_in_Y_rev}
Therefore, it should be noted that a correction is applied between the diffusion coefficient based on the mass fraction $Y$ and that based on the absolute humidity $\omega$. This correction is generally on the order of a few percent. Rewriting Eqs. [@eq:omega_me] and [@eq:omega_ms] using this diffusion coefficient $D'$ gives

$$
Y_{\mathrm{me}} = Y_{\mathrm{ae}} + \alpha \left(
Y_{\mathrm{as}} - Y_{\mathrm{ms}}
\right)\
\alpha' = \frac{\rho_{\mathrm{as}}}{\rho_{\mathrm{ae}}} \frac{D'*{\mathrm{as}}}{D'*{\mathrm{ae}}} \frac{\Delta z_{\mathrm{ae}}}{\Delta z_{\mathrm{as}}}
$${#eq:Y_me}

and

$$
Y_{\mathrm{ms}} =\frac{
\beta Y_{\mathrm{ae}} + (\alpha \beta  + 1)Y_{\mathrm{as}}
}{
\alpha + \alpha \beta + 1
}\
\beta' = \frac{\rho_{\mathrm{m}}}{\rho_{\mathrm{as}}} \frac{D'*{\mathrm{m}}}{D'*{\mathrm{as}}} \frac{\Delta z_{\mathrm{as}}}{\delta} \frac{1}{\psi}
$${#eq:Y_ms}

Although the discussion so far has proceeded starting from $\omega$, in general, the $D'$ used here should be regarded as the physical diffusion coefficient data provided. On that basis, if conversion to $\omega$ or other variables is required, the differential coefficients should be converted each time.

## Evaluation of membrane performance

Based on the theory above, the physical quantities that must be measured for modeling are as follows.

1. Sorption curve: This is the most important curve connecting the relative humidity $\phi$ of the air near the membrane and the moisture uptake $\theta$ inside the membrane. Although the effects of temperature and pressure on this curve need to be investigated, since $\phi$ itself has temperature dependence, it is desirable to obtain the curve for each operating condition defined in WP1.
   
2. Moisture diffusion coefficient inside the membrane $D'*\mathrm{m}$: In general, the diffusion coefficient is a function of temperature and moisture content, but it is often treated as a constant. The effects of temperature and moisture content need to be investigated. If it is difficult to measure $D'_{\mathrm{m}}$ alone, measuring the moisture permeability performance of the membrane as a whole is also sufficient. Although this probably depends on the measurement method, it corresponds to one of $r_{\mathrm{m}}$, $r'_{\mathrm{m}}$, $\rho_{\mathrm{m}} D_{\mathrm{m}}$, or $\rho_{\mathrm{m}} D'_{\mathrm{m}}$.

3. Membrane thickness $\delta$: Since $\delta$ has a first-order effect on $r_{\mathrm{m}}$, its error directly appears as an error in the membrane resistance. $\delta$ is generally on the order of 10 μm, so precise measurement is required. In addition, it is necessary to confirm how much it changes between the dry and moisture-absorbed states.

4. Membrane density $\rho_{\mathrm{m}}$: The apparent density in the dry state is measured. The apparent density includes voids and is therefore smaller than the density of the material itself. By considering the density of the material itself together with this value, the porosity can also be obtained.

5. Thermal conductivity $k_{\mathrm{m}}$: The thermal conductivity representing sensible heat transfer in the membrane is measured. However, the importance of this measurement is low. The overall thermal resistance accounts for both the heat transfer coefficient from the air to the membrane and this thermal conductivity, but in general, the effect of the membrane thermal conductivity on the overall thermal resistance is small. For example, even changing the membrane from paper to metal is said to improve it by only about 5%. Therefore, the dominant factor in sensible heat exchange between membranes is the heat transfer coefficient, while the thermal conductivity is auxiliary [@undated-uj].
