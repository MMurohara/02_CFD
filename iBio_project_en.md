---
documentclass: ltjsarticle
header-includes:
  - \usepackage[margin=1in]{geometry} 
  - \usepackage[version=3]{mhchem}
  - \setkeys{Gin}{width=8cm}

title: |
  Important Formulas for CFD
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

# Simulation of Multiphase Flow
When modeling multiphase-flow simulations, the following points must be clarified.
1. Whether the flow is homogeneous or inhomogeneous
2. Whether the interphase interface must be resolved accurately
3. What spatial and temporal resolution is required for the domain

## Eulerian and Lagrangian Methods
The Eulerian method solves the balance of physical quantities, such as mass, momentum, and energy, entering and leaving each cell. In other words, it is equivalent to continuously observing a fixed point in space. The Lagrangian method, on the other hand, is often considered when particles exist in a multiphase flow. In this approach, the forces acting on each particle are considered, and the equation of motion of each particle is solved. In either case, various forces acting on particles must be considered: in the Eulerian method to solve momentum conservation, and in the Lagrangian method to solve the equations of motion. Various approximate models exist for modeling these forces, and the range of applicability and accuracy vary depending on the model.

In multiphase flow, the system is generally divided into a continuous phase and a dispersed phase. The continuous phase is the background field occupying most of the domain, such as water or air. The dispersed phase refers to particles dispersed within the continuous phase. The continuous phase is generally solved using the Eulerian method, whereas the dispersed phase is treated either by the Eulerian method or the Lagrangian method depending on the phenomenon of interest. When the Eulerian method is also used for the dispersed phase, the approach is called the Eulerian--Eulerian (EE) method. When the Lagrangian method is used for the dispersed phase, it is called the Eulerian--Lagrangian (EL) method.
The EE method defines a mixture fraction in each cell, or a volume fraction in the case of bubbles or solid particles, and solves a continuous distribution over the entire domain. Since it tracks the entire domain instead of resolving the motion of individual particles in detail, it is useful when the concentration of the secondary phase is high throughout the domain. However, because of this treatment, the interface can become smeared in the Eulerian method, meaning that physical quantities can influence neighboring cells across the physical boundary. When the interface must be resolved accurately in the Eulerian method, VOF (Volume of Fluid) is used. In that case, the mesh spacing must of course be fine enough to resolve the interface accurately. The Eulerian method is further classified into homogeneous and inhomogeneous models. In the homogeneous model, the multiphase flow in each cell is assumed to be in complete equilibrium. That is, the velocity, temperature, momentum, and other quantities of each phase are the same within the cell. In contrast, the inhomogeneous model allows each phase to have different physical quantities within each cell.
The EL method, on the other hand, solves the equation of motion of each particle. Since the particles are calculated as point masses with no volume, there is no requirement for the cell size relative to the particle size. However, the forces acting on particles are strongly affected by the continuous-phase field, so the cell size must still be fine enough to compute the continuous-phase field adequately. In addition, because the Lagrangian method tracks individual particles, simulations with high particle concentration require substantial computational resources. In general, it is applied to dilute dispersed flows where individual particles do not significantly affect each other.
Now consider the simulation of a bubble column. In a bubble column, the motion of individual bubbles in the liquid is undoubtedly important. In this case, the EL method is suitable. On the other hand, if the focus is on situations where bubbles repeatedly collide, split, and grow larger, or on relatively large gas--liquid interface motions such as oscillations of the interface between the atmosphere and the liquid surface, one would need to solve both the motion of individual small bubbles and the motion of the large interface. This would lead to unnecessarily high computational cost. In such cases, a hybrid model may be used. That is, the Lagrangian method using DPM is used for bubble injection and small bubbles before coalescence, while the VOF method is used to calculate the interfacial behavior at the liquid surface. In Fluent, VOF and DPM can each define independent dispersed phases. Therefore, care must be taken because if the inflow of the dispersed phase is defined both in VOF and DPM, the dispersed phase may be counted twice. In addition, appropriate settings, such as User Defined Functions, are required to exchange information between DPM and VOF.

# Simulation of a Bubble Column
Bubble-column simulation has become increasingly important in recent years. However, because there are many settings, including calculation conditions, turbulence models, and coefficients for each force, it is very difficult to validate the model and identify the causes of discrepancies between computational and experimental results.

In the following, air injection into water is considered.

## Courant Number
Bubble-column simulations treat bubble motion at each time instant in an unsteady flow. Therefore, the Courant number is very important. The Courant number $C$ is expressed as

$$
C = \frac{v \Delta t}{\Delta x}
$${#eq:Courant_number}

where $v$ is the flow velocity, $\Delta t$ is the time step, and $\Delta x$ is the representative cell length. The Courant number is a dimensionless number that represents how many cells the flow travels during a given time step in a numerical calculation. It is an important value expressing the Courant condition, or CFL condition, which states that the speed at which information propagates in the numerical calculation ($\Delta x / \Delta t$) must be faster than the speed $v$ at which physical quantities propagate in the actual phenomenon; in other words, $C < 1$ must be satisfied. For example, if the time step is 0.01 s, the element width is 5 mm, and the representative velocity is 0.5 m/s, the Courant number becomes 1. It may be better to make the spatial spacing slightly larger or the time step smaller so that the Courant number is around 0.5.

## Bubble Motion
Bubble motion in a bubble column can mainly be divided into three phases:
1. Bubble growth due to gas supply
2. Bubble detachment from the injector
3. Bubble rise

In a bubble column, both the gas and liquid phases are assumed to be incompressible. If the bubbles are assumed to be at room temperature and atmospheric pressure, they are affected not only by atmospheric pressure but also by hydrostatic pressure. If the height of the bubble column is $h$, the ratio of hydrostatic pressure to atmospheric pressure is $\rho_{\mathrm{l}} h g / P_0$. Plotting this ratio as a function of bubble-column height gives a result such as [@fig:Water_pressure_impact]. Therefore, when the bubble-column height exceeds 10 m, the effect of hydrostatic pressure starts to exceed that of atmospheric pressure, and compressibility likely needs to be considered. However, for a laboratory-scale bubble column of around 1 m, the compressive effect of hydrostatic pressure can be neglected, and the incompressible assumption is acceptable.

![Water pressure/atmospheric pressure vs. height of water.](img/Water_pressure_impact.png){#fig:Water_pressure_impact}

### Bubble Growth
Here, a single orifice is considered as the injector. The orifice diameter is denoted by $d_{\mathrm{o}}$.

### Bubble Detachment
#### Bubble Volume at Detachment
Bubble detachment can be broadly divided into three phases: the Single period, Double period, and Triple period. Roughly speaking, the larger the air-supply flow rate and velocity, the stronger the influence between detaching bubbles becomes. The effect of the air-supply rate is organized using the orifice Reynolds number $Re_{\mathrm{o}} = v_{\mathrm{g}} d_{\mathrm{o}} / \nu_{\mathrm{g}}$. Here, $v_{\mathrm{g}}$ is the gas velocity at the orifice, and $\nu_{\mathrm{g}}$ is the kinematic viscosity of the gas.
The larger the orifice Reynolds number, the larger the generated bubble becomes. This is organized using the dimensionless volume $\bar{V}$ defined below. The dimensionless volume is defined as the ratio of the bubble volume at detachment $V_{\mathrm{b}}$ to the reference volume $V_{0}$, as follows.

$$
\begin{aligned}
\bar{V} &= \frac{V_{\mathrm{b}}}{V_0}\\
V_0 &= \frac{\pi d_{\mathrm{o}} \sigma}{(\rho_{\mathrm{l}} - \rho_{\mathrm{g}}) g}
\end{aligned}
$${#eq:dimensionless_volume}

In the Single period, the bubble volume can be assumed spherical, but in the other periods the bubble is not necessarily spherical, so determining its volume is not easy. Since bubbles in a bubble column are generally treated as incompressible gas, the volume is obtained as follows.

$$
V_{\mathrm{b}} = \int_0^{t_{\mathrm{d}}} q \; dt
$${#eq:def_bubble_volume}

Here, $q$ is the volumetric flow rate at the orifice. The reference volume is the volume at which buoyancy, $F_{\mathrm{buoyancy}} =V_{\mathrm{b}} (\rho_{\mathrm{l}} - \rho_{\mathrm{g}}) g$, balances the surface-tension force, $F_{\mathrm{surface \; tension}} = \pi d_{\mathrm{o}} \sigma$. It can also be regarded as the volume at which the Eotvos number is 1.

A map of the orifice Reynolds number and dimensionless volume is shown in [@fig:bubble_detachment_mapping] [@Zhang2001-es].

![Map of Orifice Re vs. Dimensionless bubble volume.](img/bubble_detachment_mapping.png){#fig:bubble_detachment_mappingw}

In the figure, during Single bubbling within the Single period, each bubble forms without being affected by the previous bubble, so the bubble detachment period remains constant. From Eq. [@eq:def_bubble_volume], when the detachment period is constant, the bubble volume also becomes constant. In the other periods, however, interactions between bubbles cause differences in the detachment periods of successive bubbles. As a result, several theoretical lines appear.

In the Single period, the bubbles that are generated and detached rise while maintaining a certain separation distance, and they do not collide with each other. Within the Single period, in the range $Re_{\mathrm{o}} < 200$ (Single bubbling), successive bubbles are independent of each other, and interactions can be neglected. On the other hand, in the range $200 < Re_{\mathrm{o}} < 480$ (Pairing), the bubble is slightly affected by the preceding bubble. As a result, two bubbles detach with somewhat different volumes, but they do not collide. When $480 < Re_{\mathrm{o}}$, coalescence occurs due to collisions between two or three successive bubbles. This causes bifurcation of the detachment period. In a bubble column, the usual objective is to generate a large number of small bubbles and increase the surface area. Therefore, operating in the Single period seems preferable.

#### Bubble Velocity at Detachment
In a bubble column, bubble velocity must be considered separately at detachment, during acceleration, and at steady state [^Fluent_DPM].

[^Fluent_DPM]:
In Ansys Fluent multiphase-flow simulations, the initial bubble velocity is specified in Eulerian and DPM models. However, studies attempting to reproduce the experiments of Deen et al. [@Deen2000-pw], such as [@Deen2001-ed; @Yang2022-ke; @Xue2017-gb; @Subburaj2023-bv], do not mention the initial bubble velocity at all and instead report the superficial gas velocity. My understanding is that the superficial gas velocity is the volumetric flow rate normalized by a representative area and is not appropriate as the bubble velocity. Further investigation is needed on this point.


### Bubble Rise

#### Terminal Velocity


#### Forces Acting on a Rising Bubble
The forces that should be considered when a bubble rises are shown in [@fig:interphase_forces_in_bubble_flow] [@Wang2016-uc]. These are classified into drag and non-drag forces. The non-drag forces include virtual mass force, wall lubrication force, lift force, and turbulent dispersion force. The word lubrication may sound unfamiliar, but it means reducing friction by a lubricating layer or effect.

![Illustration of the interphase forces in bubbly flow.](img/Interphase_forces_in_bubble_flow.png){#fig:interphase_forces_in_bubble_flow}

##### Drag Force
As the term suggests, drag is the resistance force that a bubble receives from the liquid when it moves through the liquid, and it is proportional to the velocity difference between the bubble and the liquid. In general, the drag force is expressed as

$$
F_{\mathrm{D}}=\frac{3}{4} \frac{C_{\mathrm{D}}}{d_{\mathrm{b}}} \rho_{\mathrm{l}} \alpha_{\mathrm{l}} \alpha_{\mathrm{g}} |v_{\mathrm{g}} - v_{\mathrm{l}}| (v_{\mathrm{g}} - v_{\mathrm{l}})
$${#eq:drag_force}

where $C_{\mathrm{D}}$ is the drag coefficient, $d_{\mathrm{b}}$ is the bubble diameter, $\rho$ is the mass density, $\alpha$ is the volume fraction, and $v$ is the velocity. The subscripts $\mathrm{l}$ and $\mathrm{g}$ denote the liquid and gas phases, respectively. Various models have been proposed to determine the drag coefficient. It is known that the drag coefficient strongly depends on the Reynolds number and bubble shape, and the bubble Reynolds number and Eotvos number are introduced to organize these effects.
The bubble Reynolds number is, as the name suggests, the Reynolds number for the bubble and is given by

$$
Re_{\mathrm{b}} = \frac{\rho_{\mathrm{l}} |v_{\mathrm{g}} - v_{\mathrm{l}}| d_{\mathrm{b}}}{\mu_{\mathrm{l}}}
$${#eq:bubble_Re}

where $\mu$ is the dynamic viscosity. The Eotvos number is

$$
Eo = \frac{F_{\mathrm{bouyancy}}}{F_{\mathrm{surface \;tension}}} = \frac{\Delta \rho g d_{\mathrm{b}}^2 }{\sigma}
$${#eq:bubble_Eo}

where $\sigma$ denotes the surface tension of the liquid phase; for water at room temperature and atmospheric pressure, 0.072 N/m is often used. Here, buoyancy can be interpreted as the force that tends to deform the bubble shape, while surface tension is the force that tends to keep the bubble spherical. More precisely, the Eotvos number is the ratio of the force that tends to deform the shape to the force that tends to maintain the shape. For bubbles in liquid, these representative forces are buoyancy and surface tension. When $Eo \ll 1$, the bubble is spherical; when $Eo \approx 1-40$, it is approximately ellipsoidal; and when $Eo \gg 40$, it is considered deformed. For example, in the experiments by Deen et al., the bubble diameter is 4 mm, so $Eo = 2.17$, suggesting that the bubbles were nearly spherical ellipsoids. Returning to the drag coefficient, among the various models, the Ishii--Zuber model appears to be commonly adopted in CFD models of bubble columns【REF to be added】. The Ishii--Zuber model is a simplified version of the model by Grace et al. When $Eo$ is small and the bubble is spherical, the drag coefficient is expressed as a function of the bubble Reynolds number. Once deformation starts, the drag coefficient is expressed as a constant independent of the bubble Reynolds number. Thus, the drag coefficient in the Ishii--Zuber model is determined by the following conditional expression.

$$
C_{\mathrm{D}} = \mathrm{max} ( \mathrm{min} (C_{\mathrm{D, ellipse}}, \; C_{\mathrm{D, cap}}), \; C_{\mathrm{D,sphere}})
$${#eq:Cd_Ishii_Zuber}

$$
C_{\mathrm{D, sphere}} = \mathrm{max} \left(
  \frac{24}{Re_{\mathrm{b}}} \left( 1 + 0.15Re_{\mathrm{b}}^{0.687} \right), \;
  0.44
\right)
$${#eq:Cd_sphere}

$$
C_{\mathrm{D,ellipse}} = \frac{2}{3} Eo^{1/2}
$${#eq:Cd_ellipse}

$$
C_{\mathrm{D,cap}} = \frac{8}{3}
$${#eq:Cd_cap}

Here, $C_{\mathrm{D, sphere}}$ is equivalent to the Schiller--Naumann model. It should also be noted that $C_{\mathrm{D, ellipse}}$ is applicable only in the range $Re_{\mathrm{b} > 1000}$.

##### Virtual Mass Force
Among the non-drag forces, the virtual mass force becomes important when a bubble is accelerated in a liquid. A bubble accelerating relative to the liquid experiences an inertial force proportional to the acceleration, and this behaves as if the bubble had a virtual mass. Since this force is proportional to the difference in acceleration between the phases, it is generally neglected in steady flows [@Wang2016-uc]. On the other hand, it plays an important role in flows with large acceleration, such as flows through contractions. Fluent also notes that this force is particularly important in cases such as unsteady bubble columns, where the gas-phase density is sufficiently small relative to the liquid-phase density [@Ansys2025-qg]. The virtual mass force is given by

$$
F_{\mathrm{VM}} = C_{\mathrm{VM}} \alpha_{\mathrm{b}} \rho_{\mathrm{l}} \left(
\frac{d v_{\mathrm{b}}}{dt} - \frac{d v_{\mathrm{l}}}{dt}
\right)
$${#eq:virtual_mass_force}

where $C_{\mathrm{VM}}$ is the virtual mass force coefficient, typically given as 0.5. However, it should be noted that this value was obtained as the theoretical solution for a solid sphere in potential flow [@2018-nc]. Therefore, when applying it to bubbles in a bubble column, it would be safer to first confirm from the Eotvos number that the bubbles are spherical and then set $C_{\mathrm{VM}}=0.5$. Further investigation is needed for the virtual mass force coefficient when the bubble shape is ellipsoidal or distorted.

# Oxygen Transfer from Bubbles to Water
The purpose of supplying bubbles in a bubble column is, in the first place, to supply oxygen to the mother liquid. For example, in wastewater treatment tanks, microorganisms are used to decompose organic matter, so the oxygen concentration must be maintained at a certain level. Dissolved oxygen concentration in water is also very important when keeping fish in aquariums or aquaculture facilities. Here, the physics of oxygen transfer from bubbles to water is summarized.
The commonly adopted transfer model is the two-thin-film model. In this model, oxygen in a bubble passes through the gas film, the gas--liquid interface, and the liquid film before dissolving into the liquid. The film can be regarded as a boundary layer near the gas--liquid interface; it is expressed as a pressure boundary on the gas side and as a concentration boundary on the liquid side. The oxygen transfer capacity coefficient is considered at each location. However, for sparingly soluble gases such as oxygen, the transfer capacity coefficient in the liquid film is generally dominant, so the liquid-side mass transfer capacity coefficient $k_{\mathrm{L}}a$ is treated as approximately equal to the overall mass transfer capacity coefficient ${K_{\mathrm{L}}a}$. Here, $k_{\mathrm{L}}$ is the liquid-film oxygen transfer coefficient [m/s], and $a$ is the gas--liquid interfacial area [m-1]. In a homogeneous flow, if the bubble diameter $d$ is known,

$$
a = \frac{6 \varepsilon_{\mathrm{G}}}{d}
$${#eq:gas_surface_area}
where $\varepsilon_{\mathrm{G}}$ is the gas holdup, which is synonymous with the gas volume fraction or void fraction in the bubble column. In the present case, where the flow is homogeneous and there is no circulating liquid flow, the gas holdup can also be expressed using the bubble slip velocity $u_{\mathrm{s}}$ and the superficial gas velocity $u_{\mathrm{G}}$ as

$$
u_{\mathrm{s}} = \frac{u_{\mathrm{G}}}{\varepsilon_{\mathrm{G}}}
$${#eq:slip_vel}

Using these values, the mass transfer rate $S_{\mathrm{O_2}}$ through the gas--liquid interface is

$$
S_{\mathrm{O_2}} =K_{\mathrm{L}}a \rho_{\mathrm{L}} \left(
  y_{\mathrm{L}}^{*} - y_{\mathrm{L}}
 \right)
$${#eq:m_dot}

where $y_{\mathrm{L}}$ is the mass fraction of oxygen in the liquid, and $y_{\mathrm{L}}^{*}$ is the saturated mass fraction of oxygen in the liquid. Multiplying these by $\rho_{\mathrm{L}}$ gives an expression in which the driving force is the mass-concentration difference. Therefore, note that the unit of the mass transfer rate $S_{\mathrm{O_2}}$ here is $\mathrm{[kg \; m^{-3} \; s^{-1}]}$. The following assumptions are made here.

* Oxygen transfer from bubbles to the liquid through the gas--liquid interface is dominated by the liquid-film mass transfer capacity coefficient.
  
* Oxygen dissolved into the mother liquid through the liquid film diffuses sufficiently rapidly within the mother liquid, and the oxygen concentration in the mother liquid becomes uniform sufficiently quickly.

* Oxygen transfer at the free interface of the upper liquid surface is neglected.

$y_{\mathrm{L}}^{*}$ is mainly obtained from Henry's law. However, Henry's law can be expressed in several forms, such as mass fraction and mole fraction, and the Henry's law expression available here was written in terms of the saturated mole fraction in the liquid phase, $x_{\mathrm{L}}^{*}$. That is, using the Henry constant $H$,

$$
x_{\mathrm{L}}^{*} = \frac{p_{\mathrm{O_2}}}{H}
$${#eq:henry}

where $p_{\mathrm{O_2}}$ is the oxygen partial pressure on the bubble side. The Henry constant is a physical property determined by the combination of substances, such as water and oxygen, and by temperature. It is tabulated in sources such as chemical handbooks [@1999-jx]. For oxygen, it can be obtained from the following equation. Care must be taken with the unit of the Henry constant, and appropriate unit conversion is required.

$$
\begin{aligned}
\ln (H/H_0) &= A(1-T_0/T) + B\ln (T/T_0) + C(T/T_0 - 1)\\
H_0 &= 4420 \times 10^6 \; \mathrm{Pa}\\
T_0 &= 298.15 \; \mathrm{K}\\
A &= 29.339\\
B &= -24.453\\
C &= 0
\end{aligned}
$${#eq:Henry_t}

The applicable temperature range is $273 \; \mathrm{K} < T < 349 \; \mathrm{K}$. At 25 degrees Celsius, using $T = 298.15 \mathrm{K}$ gives $H = 4.36 \times 10^4 \; \mathrm{atm / (mol \; fraction \; at \; liquid \; side)} \approx 4.42 \times 10^9 \; \mathrm{Pa / (mol \; fraction \; at \; liquid \; side)}$. For water at 25 degrees Celsius and 1 atm, the oxygen partial pressure in the bubble is 0.21 atm. Therefore, from [@eq:henry] and [@eq:Henry_t], the saturated oxygen concentration is $4.8 \times 10 ^{-6}$ in mole fraction and approximately $8.53 \times 10^{-6}$ in mass fraction. Since Fluent normally uses mass fraction, this conversion is important.

Now, $K_{\mathrm{L}}a$ is affected by many factors. It depends on the superficial velocity, bubble diameter, bubble shape, presence or absence of meandering, and other factors, and it generally seems to be obtained experimentally. Since the 2010s, numerical approaches to obtain it have gradually been used as well; this will be discussed later. Thus, by integrating [@eq:dC_dt], one obtains

$$
{K_{\mathrm{L}}a} = \frac{1}{t_2 - t_1}
\ln \left(
  \frac{C_{\mathrm{L}}^{*} - C_{\mathrm{1}}}{C_{\mathrm{L}}^{*} - C_{\mathrm{2}}}
\right)
$${#eq:dC_dt_int}
By measuring the dissolved oxygen concentration at times $t_1$ and $t_2$ using a concentration meter, for example a DO-31P from TOA DKK, $K_{\mathrm{L}}a$ can be obtained.

The oxygen supply capacity is evaluated using the oxygen transfer efficiency, OTE (Oxygen Transfer Efficiency). OTE is expressed as

$$
OTE = \frac{K_{\mathrm{L}} a C_{\mathrm{L}}^* V}
{G_{\mathrm{s}} \rho_{\mathrm{G}} O_{\mathrm{w}}}
$${#eq:OTE}

where $V$ is the liquid-phase volume, $G_{\mathrm{s}}$ is the volumetric flow rate of the supplied air, $\rho_{\mathrm{G}}$ is the air density, and $O_{\mathrm{w}}$ is the oxygen mass content in air $(=0.233 \; \mathrm{O_2-kg/ Air-kg} )$.

## Model for the Mass Transfer Coefficient $k_{\mathrm{L}}$
The most important physical quantity is the mass transfer coefficient $k_{\mathrm{L}}$, and various models have been proposed. However, as of 2022, a unified view on which model is best does not appear to have been established. The simplest model is the single-bubble model. As the name suggests, this is a model of mass transfer from a single bubble and is thought to be useful when the supplied air flow rate is small and the bubble column operates in the Single bubbling regime. In this model, $k_{\mathrm{L}}$ is expressed using the Sherwood number. That is,

$$
k_{\mathrm{L}} = \frac{Sh D_{\mathrm{AB}}}{d}
$${#eq:kL_by_Sh}

where $Sh$ is the Sherwood number, $D_{\mathrm{AB}}$ is the diffusion coefficient of the target component in the liquid phase [m2/s], and $d$ is the representative length, for which the bubble diameter is generally used. $D_{\mathrm{AB}}$ is temperature-dependent, but in pure water at 25 degrees Celsius it is $1.97 \times 10^{-9} \mathrm{m^2/s}$. The correlation for the Sherwood number is difficult, and Fluent seems to use a Ranz--Marshall-type correlation. The Ranz--Marshall equation is derived based on the analogy between heat and mass transfer from a spherical object to a fluid.

$$
Sh = 2.0 + 0.6 Re^{1/2} Sc ^{1/3}
$${#eq:Sh}

Here, the Reynolds number is calculated using the slip velocity as

$$
Re = \frac{\rho_{\mathrm{L}} |u_{\mathrm{G}} - u_{\mathrm{L}}| d}{\mu_{\mathrm{L}}}
$${#eq:Re}

The Schmidt number is obtained from the properties of the liquid phase as

$$
Sc = \frac{\mu_{\mathrm{L}}}{\rho_{\mathrm{L}} D_{\mathrm{AB}}}
$${#eq:Sc}

The coefficients and exponents in [@eq:Sh] vary somewhat depending on the model. Here, the simplest Ranz--Marshall-type correlation is shown, but many Sherwood-number models have actually been proposed. Important conditions appear to include the size ratio between the bubble and tank, bubble shape, characteristics of the bubble plume, such as whether it is a single bubble or a double bubble, and the presence or absence of bubble-surface oscillation.

In Higbie's unsteady penetration model, $k_{\mathrm{L}}$ is expressed as follows.

$$
k_{\mathrm{L}} = 2 \sqrt{
  \frac{D_{\mathrm{AB}} u_{\mathrm{s}}}
  {\pi d}
}
$${#eq:kL_higbie}
This model is applicable in approximately the range $20 < Re \le 500$. It is also known to agree particularly well when the bubble diameter is small, 3.6 mm or less.

## Influence of Other Components
As a simple model in this study, only the dissolution of oxygen from bubbles into water is considered. Naturally, in this case, a component is only removed from inside the bubble, so either the bubble diameter decreases or the bubble density decreases. In the model based on the experiments of Deen et al. used here, the bubble diameter is fixed at 4 mm, so the bubble density decreases. On the other hand, the bubble is subjected to atmospheric pressure plus hydrostatic pressure, so the force balance is disturbed. No breakdown due to this imbalance has occurred during the simulations, so it may not be a major problem. However, problems may occur when the water tank is tall and the residence time of bubbles in the water is long. Fundamentally, the transfer of other components such as nitrogen and CO2 should probably also be included in the model.

# Notes on Ansys Fluent
## Boundary-Condition Settings
The inlet boundary condition (BC) and outlet boundary condition are set separately. At the inlet boundary, known physical quantities should be specified as much as possible. Although a velocity boundary is commonly used, a mass-flow-rate boundary is apparently more numerically stable. On the other hand, the outlet boundary should be determined with the aim of imposing as few constraints as possible on the calculation. In general, a static-pressure condition is often used, but in a bubble column it is necessary to consider both the continuous and dispersed phases. It may also become necessary to consider the behavior at the free surface of the water. Therefore, the outlet BC is particularly important.

When deciding the outlet boundary, the domain setting naturally comes first. There are generally two approaches: an open domain and a closed domain [^meshing_approach].
1. Open domain: Both the liquid and gas phases are defined in the domain. In this case, because there is also flow in the gas region, the gas region must be made sufficiently large. A classical outlet condition, probably a static-pressure condition, is imposed at the outlet at the top of the gas region. Under this outlet condition, the liquid phase of course cannot flow back in, so the volume fraction is set to gas only. In this open domain, the free surface of the water is also calculated, which creates challenges in numerical stability.
2. Closed domain: The entire domain is filled with the liquid phase. The outlet is set at the initial water-surface height in the experiment. Under the incompressible assumption, the dispersed phase is supplied into this domain, but since the domain is filled with the liquid phase, there is no place for the dispersed phase to enter, and the conservation laws are not satisfied. Therefore, special treatment of the conservation laws is required, but when using commercial software this is automatically performed depending on the software. In a closed domain, it seems common to discharge only the dispersed phase from the domain using a degassing or gas-only outlet as the outlet boundary. In this case, the liquid surface is fixed at the domain outlet and treated as a free-slip wall for the liquid phase. Because there is no need to solve the free surface and no gas region exists, the number of cells can be reduced and computational efficiency improved. In this domain, backflow may occur at the outlet boundary. In such a case, gas-phase backflow is not physically possible in the model, so care must be taken in the settings. That is, the volume fraction should be set to liquid only.

Although each domain and boundary-condition setting has its own points requiring attention, it has been shown that if a sufficiently long calculation time, more than 1000 seconds (!), is used in bubble-column calculations and time averaging or similar processing is performed, the outlet boundary condition does not affect the calculation results. From the viewpoint of computational cost, using a closed domain with a degassing condition seems to be the simplest approach [@Schlegel2025-ud].

[^meshing_approach]:
There is also an approach in which the mesh is cut to match the water surface and then updated according to the motion of the water surface, but that is too advanced and is not treated here.

### Degassing Condition
In the degassing condition, only the gas phase passes through the boundary, while the liquid phase is treated as a free-slip wall. The passage of the gas phase is expressed as disappearance from the domain. This is calculated by replacing the gas phase in the adjacent cell with liquid or by making it disappear through a sink term, although this point is not yet fully clear. In other words, the calculation is completed within the volume accumulation calculation of each cell, and the domain remains completely closed. Therefore, the concept of backflow does not exist.


## Node or Cell
Fluent is a cell-centered software, and the values solved directly are located at cell centers. It is also possible to output nodal values, but these values are interpolated values between cell centers. Therefore, when the gradient of the field is strong, such as in shocks or separation, there can be a large difference between cell-center values and nodal values. For a bubble column, either should probably be acceptable without major problems.

## Things to Do Before Running the Calculation
1. Check Case: Before running the calculation, Check Case can be used to confirm the general recommended settings for the current setup. The calculation can be run even without following the recommended settings, but especially at the current stage where knowledge is limited, it is generally better to follow them. It also points out physical inconsistencies.
2. Input summary: The case-file settings can be output as a list using Input Summary. However, it seems that detailed settings inside the model cannot be output. For multiphase flow, entering /report/mphase-summary in the Console outputs recommended settings for the current calculation setup. However, calculation data are required. After entering summary, one can specify the detail level by entering 0, 1, or 2.
3. The Modified Settings Summary can be checked from Input Summary. It shows the changes made from the default state at the time the file was opened. It is displayed in the Modified Settings Summary tab next to Graphics above the Console.
4. Autosave: When the calculation diverges, it is desirable to save dat files before the divergence so that the cause can be investigated. Saving all files results in a very large amount of data, because each dat file is several MB, so it is better to turn on the Retain only the most recent files option and save only the last 3--5 files immediately before divergence. As a personal setting, saving every 1% of the time steps and retaining the last 5 files may be a good approach.

## Calculation
1. If a .dat.h5 file is available, the calculation can be executed using its values as the initial condition. In multiphase-flow calculations, for example, the inhomogeneous Eulerian model is sensitive to the initial condition. Therefore, it is recommended to first advance the calculation to some extent using the homogeneous mixture model and then use those values as the initial condition for the inhomogeneous Eulerian calculation.

2. In Fluent, calculations are basically performed using gauge pressure, and the reference pressure, operating pressure, is specified in Operating Conditions under Physics → Solver. The reference pressure should be set at the water surface. By default, the reference pressure is set at the bottom of the water tank, so an offset corresponding to the hydrostatic pressure appears. In the present case, the water height is 0.45 m, so an offset of about 4.4 kPa is added, which affects the oxygen solubility by several percent.

3. Fluent has built-in support for mass transfer by default. Since a UDF was created before finding this function, it is unclear how far the standard function can cover the required model.

4. In a multiphase-flow model, memory for gas-phase velocity components is allocated even in cells where the gas phase does not physically exist. Numerically unstable values can appear in this memory. For example, when velocity is calculated by solving momentum conservation, a large velocity may appear locally due to numerical instability when the gas volume fraction is extremely small, such as 1E-10. Therefore, it is desirable to maintain physical consistency by applying exception handling below a certain volume-fraction threshold.

## UDF
* In a multiphase-flow model, there is a top-level superdomain and subdomains under it for each phase, such as the primary phase and secondary phase. A thread exists for each domain, and a subdomain thread, or sub-thread, is obtained using the THREAD_SUB_THREAD(Super-thread, Sub-thread) function.

* When modeling mass transfer, UDF has a built-in macro called DEFINE_MASS_TRANSFER, and its arguments are described below. During calculation, the Ansys Fluent solver scans, or loops over, all cells in the domain sequentially. Model-specific macros such as DEFINE_MASS_TRANSFER and DEFINE_PROPERTY are called for each cell currently being calculated, so it is not necessary to write a loop in the UDF. Conversely, functions that are called only once in the calculation procedure, such as at the beginning of each iteration or on demand, may need to include a loop depending on the case.
  * udf_name: The function name recognized as the UDF. To avoid conflicts with other functions, it is recommended to add a prefix such as my_.
  * cell: The cell currently being calculated.
  * thread: The thread of the superdomain (super thread).
  * from_p_index: Phase index. The primary phase is 0, and the secondary phase is 1. The direction of component transfer is specified by from and to. For example, when considering transfer from bubbles to the liquid phase as in the present case, from_p_index = 1 (secondary phase), and to_p_index = 0 (primary phase).
  * from_s_index: Component index. This specifies the index of each component when the target phase is a mixture material. In the present case, the bubble side is O2-N2, and transfer of O2 is considered, so the index is 0. The index is defined by the order of the components set in the mixture-material GUI in Fluent.
  * to_p_index
  * to_s_index

  Among these, the values that the user should specify in the code are only the constants, such as the Henry constant, liquid-film-side mass transfer coefficient, and molar mass of the transferred component, and the udf_name. The other arguments are automatically passed by Fluent, so they do not need to be hard-coded. In mass transfer, only components defined in both phases are treated. For example, if a mixture material of H2O and O2 is defined in the liquid phase and a mixture material of N2 and O2 is defined in the gas phase, only the transfer of O2, which is defined in both phases, is calculated.





