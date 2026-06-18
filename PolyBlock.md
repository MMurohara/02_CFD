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

# 緒言
## 背景
建物分野は世界のエネルギー消費のうち30%を占める．ここで空調機の負荷を下げることはCO2排出量抑制に対して地球規模の効果が見込まれる．現代の空調システムとしては一般
に熱交換器とエンタルピー交換器とがある．熱交換機は熱，すなわち顕熱のみを交換する一方で，エンタルピー交換器は水蒸気も交換する．これにより水蒸気が持つ潜熱の交換（顕熱＋潜熱でエンタルピー）の交換も可能になる．Polyblock社はエンタルピー交換器用核膜としてVAPOBLOCを製造・販売している．VAPOBLOCは吸湿性塩を含むPVA,セルロース，PVDF/PES，または特殊ポリマーなどが用いられる．この材料により水蒸気分圧による水蒸気拡散を可能にし，かつウイルスや細菌などの汚染物質をろ過できる．そのため，特に清潔さが重要な病院などにおいて一定のシェアを持つ．しかしながら，本製品は熱効率65-75%，湿度効率60-70%程度であり，一般的な熱交換器の90%程度の熱効率に対抗できない．この原因として膜の機械的弱さがある．膜厚は150-200μm程度であり，圧力差による変形が起こる．この変形は作動環境に依存し，かつ動的に変化するため各顧客に導入するにあたっての設計は簡単ではない．これまでは，同社で保有するデータや逐次的な試験によって経験的な設計が行われてきた．変形を抑制するために，支持構造が用いられる．この支持構造は高い製造負荷や圧力損失，また支持構造のために流体最適化が不可能などの原因となってしまう．上記のような課題から現在は熱交換器が主流となっている．
Polyblock社は本課題を克服したFormFlex HXを開発した．FormFlex HXは支持構造なしで3D形状を維持できる形状安定性を有している（特許番号：USP/EP3094940B1）．そのため支持構造が不要であり，圧力差による変形を考慮しなくてよい．また，本材料はスケーラブルであり住宅用装置から大型商業システムまで幅広く対応可能である．
FormFlex HXは変形が起きないために設計が簡略化される．特に動的変化が起きないことはCFDの導入ハードルを著しく下げ，顧客に対して柔軟なソリューションを提案できる．また，支持構造をなくすことで製造時のCO2排出量を25-30%減少させ，加えて廃棄物も削減することが可能である．
設計が簡略化されるとはいえ，設計空間は依然として広い．水分子の交換効率は一般に膜面積が大きくなるほどに向上するが，同時に膜面積の増加により圧力損失が高まる．また，流れは多くの場合層流であるため，タービュレータ等を導入して熱伝達の向上を図る必要がある．したがってこれらのトレードオフ問題を解かなくてはならない．すなわち，入力変数を膜面積や膜形状などの幾何条件にとり，目的関数をシステム全体の体積や効率，圧力損失とするようなメタモデルの構築が必要となる．

## プロジェクト目標
* FormFlex HXのTRLを現在のTRL5からTRL7まで引き上げる．
* 次世代EWTとして十分な性能を達成する．
  * 温度効率80%以上
  * 湿度効率70%以上
  * 圧力損失200Pa以下
  * 750Paの圧力差でも変形しないこと
  * 製造コストの上昇を現行比で20%以内に抑えること
* システム設計のためのメタモデルの構築

# 理論
## 仮定

モデル化にあたって，以下を仮定する．

1. 流れ平面方向の水分子の移動は無視する．これは参考文献[@Niu2001-es]の計算結果による．運転条件によってはこの過程が崩れることもあるため，Pe数が2以上であることを確認すること．

2. 熱・水分輸送は平衡状態である．

3. 膜における水分の拡散係数$D_{\mathrm{m}}$は定数である．

4. 吸湿，脱湿時の吸熱・放熱は定数であり，両者等しい値である．

## 交換効率
顕熱は温度交換効率，潜熱は湿度交換効率によって定義される．[@fig:POL_flow_schematics]のように各流れを定義する．ただし，各略語は以下の通りである．

* OA: Outer Air．屋外から全熱交換器へと送られる空気
* SA：Supply Air．全熱交換器を経て室内へ供給される空気
* RA：Return Air．室内から全熱交換器へと送られる空気
* EA：Exhausted Air．全熱交換器を経て室外へと排出される空気

![Shematic of a enthalpy exchanger element (corrugate/ cross flow) .](img/POL_flow_schematics.png){#fig:POL_flow_schematics}

温度を$T$，湿度を$\omega$で表せば，それぞれの交換効率$\eta_{\mathrm{t}}$および$\eta_{\mathrm{h}}$は以下のように表せる．

$$
\eta_{\mathrm{T}} = \frac{T_{\mathrm{OA}} - T_{\mathrm{SA}}}
{T_{\mathrm{OA}} - T_{\mathrm{RA}}}
$${#eq:temperature_exchange_eff}

$$
\eta_{\mathrm{\omega}} = \frac{\omega_{\mathrm{OA}} - \omega_{\mathrm{SA}}}
{\omega_{\mathrm{OA}} - \omega_{\mathrm{RA}}}
$${#eq:humid_exchange_eff}

## 支配方程式
ある物理量$\Phi$に関する輸送方程式は[@eq:governing_eq_1]で表される．

$$
\frac{\partial \rho \Phi}{\partial t} + \nabla \cdot \left( \rho u \Phi \right) =
\nabla \cdot \left( \Gamma_{\Phi} \nabla\Phi \right) + S_{\Phi} 
$${#eq:governing_eq_1}

ここで左辺第一項は非定常項，第二項は移流項（対流項）であり，右辺第一項は拡散項，第二項は生成項である．また，$u$は流速$[\mathrm{m \; s^{-1}}]$である．
[@eq:eq:governing_eq_1]を物質輸送について考えると連続の式が得られる．非圧縮性流体を仮定して$\partial \rho / \partial t = 0$とすれば連続の式は

$$
\nabla \cdot \left( \rho u \right) = 0
$${#eq:continuity_flow}

である．[@eq:continuity_flow]は全物質を考えているが，全熱交換器においては乾燥空気と水蒸気の質量輸送をそれぞれ分けて考える必要がある．すなわち

$$
\nabla \cdot (\rho u Y_i) = -\nabla \cdot j_i
$${#eq:continuity_flow_i}

となる．ここで$j_i$は質量フラックス$[\mathrm{kg \; m^{-2} \; s^{-1}}]$である．ここで流速$u$は全質量の平均流速として定義しているため，乾燥空気と水蒸気のフラックスの和は0になる．
次にエネルギーの輸送について考える．比内部エネルギー$e_{\mathrm{v}} = c_v T$，運動エネルギー$e_{\mathrm{k}} = u^2/2$，圧力エネルギー$e_{\mathrm{p}} = p/\rho$をもちいて

$$
\nabla \cdot \left( \rho u (e_{\mathrm{v}} + e_{\mathrm{k}} + e_{\mathrm{p}}) \right) =
\nabla \cdot \left( \lambda \nabla T - \sum_i h_i j_i \right)
$${#eq:energy_conservation}

となる．ここで$\lambda$は熱伝導率，$T$は温度，$h$は比エンタルピーであり，$h = e_{\mathrm{v}} + e_{\mathrm{k}} + e_{\mathrm{p}}$である．Liuらの論文[@Liu2025-mz]においては膜の両表面で水蒸気の潜熱移動が打ち消しあうことから右辺第二項を0として扱っている．しかしながら，供給空気・排気空気主流も含めた熱交換器内の現象全体を扱う支配方程式として，膜表面のみでしか起きない潜熱移動を理由に第二項を0とするのは不適切と思われる．ここでは潜熱移動は膜表面の境界条件として与えることが適切であろう．つまり，膜表面において

$$
- \lambda_{\mathrm{m}} \frac{\partial T_{\mathrm{m}}}{\partial z} = \alpha_{\mathrm{h}} \left(T_{\mathrm{a}} - T_{\mathrm{m}} \right) + j_{\mathrm{v}} L_{\mathrm{v}}  
$${#eq:bc_energy}

である．ここで$\alpha_{\mathrm{h}}$は膜表面の熱伝達係数，$j_{\mathrm{v}}$は水蒸気の質量フラックス，$L{\mathrm{v}}$は水蒸気の吸湿・脱湿熱である．ここで，空気側から膜側への水蒸気フラックスを正としている．また，添え字は$\mathrm{a}$は空気，$\mathrm{m}$は膜，$\mathrm{v}$は水蒸気を表す．


## 水分フラックスの$\omega$による表示
本解析で最も重要になるのは水分の物質輸送に関するモデル化，すなわち[@eq:continuity_flow_i]における$j$のモデル化である．．これから説明するモデルは2001年にJ.L. NiuおよびL.Z. Zhangによって構築され[@Niu2001-es]，その後2025年の最新論文[@Liu2025-mz]に至るまで採用されている．本モデルにおいて，空気中の絶対湿度$\omega$，空気中の相対湿度$\phi$および膜中の絶対湿度$\theta$の三つの水分表示が出てくる．それぞれの定義式は以下のとおりである．

$$
\omega = \frac{m_{\mathrm{vapor}}}{m_{\mathrm{dry \, air}}}
$${#eq:def_omega}

$$
\phi = \frac{p_{\mathrm{vapor}}}{p_{\mathrm{sat}}}
$${#eq:def_phi}

$$
\theta = \frac{m_{\mathrm{vapor}}}{m_{\mathrm{dry \, membrane}}}
$${#eq:def_theta}

ここで$m$は質量，$p$は圧力を示す．また，Fluentにおいては一般に構成化学種ごとの質量比$Y$が用いられる．すなわち

$$
Y_{\mathrm{vapor}} = \frac{m_{\mathrm{vapor}}}{m_{\mathrm{dry \, air}} + m_{\mathrm{vapor}}}
$${#eq:def_Y}
である．以降，簡単のため添え字のvaporはv，membraneはm，airはaとして表す．空気中における絶対湿度$\omega$と相対湿度$\phi$，絶対湿度$\omega$と質量比$Y$はそれぞれ以下の式で変換可能である．

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

ここで[@eq:phi_to_omega]式の第二項は5%以下であり，一般に無視される[@Niu2001-es]．
ここまでに水分の表現が全部で4つ出てきた．全熱交換の分野では慣習として$\omega$を用いて表すことが多い．一方で数値計算分野においては$Y$を用いることが多い．2013年時点で「多孔質中の水分移動についてうまく計算できない．そのため，研究者ごとにコードを自作したり，UDFでFluentを回している．」という記述がみられる[@Al-Waked2013-nv]．Fluentにおいて多孔質における流体領域は当時でも水蒸気移動（単なる移流拡散）は標準サポートされていたようなので，多孔質材のうち固体部分で吸着・拡散する水蒸気の取り扱いの話をしていると考えられる．[@Liu2025-mz]においても，2024R1のバージョンでも膜内での質量移動モデルを取り扱っておらず，UDFを用いたとの記述がある．したがって，本章ではまず$\omega$表記でのモデル化を行い，その後Fluentに対応付けるために$Y$を用いた形式に変換する．
まず膜の吸湿は平衡状態であることから，供給側空気から膜へのフラックス$j_{\mathrm{s}}$，膜内でのフラックス$j_{\mathrm{m}}$および膜から排気側空気へのフラックス$j_{\mathrm{e}}$は等しい．すなわち

$$
j_{\mathrm{s}} = j_{\mathrm{m}} = j_{\mathrm{e}}
$${#eq:flux_equ}

である．ここで，フラックスの単位は$[\mathrm{kg \; m^{-2} \; s^{-1}}]$である．空気中における水分フラックス$j_{\mathrm{s}}$および$j_{\mathrm{e}}$は吸気側，排気側に関わらずフィックの法則で表される．すなわち

$$
j_{\mathrm{s}} =j_{\mathrm{e}} = - \rho_{\mathrm{a}} D_{\mathrm{a}} \frac{\partial \omega}{\partial z}
$${#eq:fick_law}

である．ここで，$D$は$\omega$に対する拡散係数[$\mathrm{m^2 \; s^{-1}}$]であり，後述の$Y$への変換では異なる値になることに注意する．次に膜内のフラックス$j_{\mathrm{m}}$を考える．これを考えるにあたって，膜近傍空気の$\omega$と膜表面の$\theta$との関係を求める必要がある．この$\theta$は膜材料特性や湿度に強く依存し，実験的に求める必要がある．例えばVapor absorption analyzer - Hydrosorb-1000[@Zhang2008-sa]などの分析器を用いる．この分析により，sorption curve（吸着等温線）を取得する．sorption cuveは横軸に相対湿度$\phi$をとり，縦軸に膜の絶対湿度$\theta$をとり，以下の式で表現される．

$$
\theta = \frac{w_{\mathrm{max}}}
{1-C+C/\phi}
$${#eq:sorption_curve}

ここで，$w_{\mathrm{max}}$は$\phi$が100\%の時の$\theta$である．$C$が主に膜や吸湿材のタイプを示す変数である．例えばもっともよく使用されるシリカゲルは$C \approx 1$であり，ポリマー材料は$C \approx 10$程度を示す．$C$ごとのsorption curveを[@fig:POL_sorption_curve]に示す．

![Sorption curves with representative $C$ numbers.](img/POL_sorption_curve.png){#fig:POL_sorption_curve}

このsorption curveを実験的に求めることで膜表面における$\theta$がわかった．この水分が膜中を拡散するとき，膜の拡散係数を$D_{\mathrm{m}} \; [\mathrm{m^2 \; s^{-1}}]$とすれば，膜内の水分のフラックスは

$$
j_{\mathrm{m}} = - \rho_{\mathrm{m}} D_{\mathrm{m}}\frac{\partial \theta}{\partial z}
$${#eq:vapor_flux_in_membrane}

としてあらわされる．例えば紙の拡散係数は約$6 \times 10^{-12} \; \mathrm{m^2 \; s^{-1}}$である．この式は$\theta$で表記されているため，$\omega$に変換する必要がある．変換のため，膜の厚みも考慮した膜抵抗$r_{\mathrm{m}}$を

$$
r_{\mathrm{m}} =\frac{\rho_{\mathrm{a}}}{\rho_{\mathrm{m}}} \frac{\delta}{D_{\mathrm{m}}} \psi
$${#eq:moisture_resistance}

$$
\begin{aligned}
\psi &= \left(A\frac{\partial \theta}{\partial \phi} \right)^{-1}\\
  &= \frac{\left( 1-C+C/\phi \right)^2 \phi^2}
  {A w_{\mathrm{max}} C}
\end{aligned}
$${#eq:CMDR}

として表す．ただし，ここでの$A$や$\phi$は供給空気側の値を用いる．$\rho_{\mathrm{m}}D_{\mathrm{m}}$をまとめて透湿係数$K [\mathrm{kg \; m^{-1} \; s^{-1}}]$として扱うこともある．詳細は参考文献[@Niu2001-es]を参照のこと．ここで$\psi$はcoefficient of moisture diffusive resistanceと呼ばれる．[@eq:phi_to_omega]を用いればこのCMDRは

$$
\begin{aligned}
\psi &= \left(A\frac{\partial \theta}{\partial \phi} \right)^{-1} \\
  &=  \left( A \frac{\partial \theta}{\partial \omega} \frac{\partial \omega}{\partial \phi} \right) ^{-1} \\
  &= \left( \frac{\partial \theta}{\partial \omega} \right)^{-1}
\end{aligned}
$${#eq:CMDR_rev}

と変形できる．すなわち，膜内の水分フラックスは式[@eq:vapor_flux_in_membrane]，[@eq:moisture_resistance]，[@eq:CMDR_rev]を用いて

$$
j_{\mathrm{m}} = -\frac{\rho_{\mathrm{a}} \delta }{r_{\mathrm{m}}}\frac{\partial \omega}{\partial z}
$${#eq:vapor_flux_in_membrane_rev}
となる．
以上，式[@eq:flux_equ]，[@eq:fick_law]，および[@eq:vapor_flux_in_membrane_rev]により，供給側空気から膜へ，膜内部から膜外部へ，膜から排気側空気への水分フラックスのすべてがあらわされた．

[@eq:flux_equ]を離散化したうえで解くことで，$\omega_{\mathrm{m}}$を空気の$\omega_{\mathrm{a}}$のみで表すことができる．離散化のため，以下の添え字を定義する．

* as: air at supply flow

* ms: membrane surface at supply side

* me: membrane surface at exhaust side

* ae: air at exhaust flow

また，膜表面から隣接空間セル中心までの距離を$\Delta z$，膜厚さを$\delta$とする．これにより

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

である．$j_{\mathrm{s}} + j_{\mathrm{e}} = 0$，$j_{\mathrm{s}} + j_{\mathrm{m}} = 0$を解けば

$$
\omega_{\mathrm{me}} = \omega_{\mathrm{ae}} + \alpha \left( 
  \omega_{\mathrm{as}} - \omega_{\mathrm{ms}}
\right)\\
\alpha = \frac{\rho_{\mathrm{as}}}{\rho_{\mathrm{ae}}} \frac{D_{\mathrm{as}}}{D_{\mathrm{ae}}} \frac{\Delta z_{\mathrm{ae}}}{\Delta z_{\mathrm{as}}}
$${#eq:omega_me}

および

$$
\omega_{\mathrm{ms}} =\frac{
  \beta \omega_{\mathrm{ae}} + (\alpha \beta  + 1)\omega_{\mathrm{as}}
}{
  \beta + \alpha \beta + 1
}\\
\beta = \frac{\rho_{\mathrm{m}}}{\rho_{\mathrm{as}}} \frac{D_{\mathrm{m}}}{D_{\mathrm{as}}} \frac{\Delta z_{\mathrm{as}}}{\delta} \frac{1}{\psi}
$${#eq:omega_ms}

を得る．この2式により膜表面の$\omega$がそれぞれ空気の$\omega$で表すことができる．

### 水分フラックスの$Y$による表示
ここまでに出てきた変数のうち，物性値として定数とおけるものは各密度$\rho$および各拡散係数$D$である．このうち，Fluentで保持されている拡散係数のデータは質量分率勾配を基準としたものである．ここまで，熱交換器分野の慣習に従って$\omega$を用いてフィックの法則を表していたが，これをFluentに対応する形に書き換えれば

$$
\begin{aligned}
j &= - \rho D \frac{\partial \omega}{\partial z}\\
  &= - \rho D \frac{\partial Y}{\partial z} \frac{\partial \omega}{\partial Y}\\
  &= - \rho \frac{D}{(1-Y)^2} \frac{\partial Y}{\partial z}
\end{aligned}
$${#eq:fick_law_in_Y}
と書き換えられる．そこで$Y$基準での拡散係数を$D'$とすれば,$D' = D / (1-Y)^2$を用いて

$$
\begin{aligned}
j = - \rho D' \frac{\partial Y}{\partial z}
\end{aligned}
$${#eq:fick_law_in_Y_rev}
が得られる．すなわち，質量比$Y$基準と絶対湿度$\omega$基準の拡散係数では補正がかかることに注意する．この補正は一般に数\%程度になる．この拡散係数$D'$を用いて式[@eq:omega_me]および[@eq:omega_ms]を書き換えれば

$$
\begin{aligned}
Y_{\mathrm{me}} &= Y_{\mathrm{ae}} + \alpha' \left( 
  Y_{\mathrm{as}} - Y_{\mathrm{ms}}
\right)\\
\alpha' &= \frac{\rho_{\mathrm{as}}}{\rho_{\mathrm{ae}}} \frac{D'_{\mathrm{as}}}{D'_{\mathrm{ae}}} \frac{\Delta z_{\mathrm{ae}}}{\Delta z_{\mathrm{as}}}
\end{aligned}
$${#eq:Y_me}

および

$$
\begin{aligned}
Y_{\mathrm{ms}} &=\frac{
  \beta' Y_{\mathrm{ae}} + (\alpha' \beta'  + 1)Y_{\mathrm{as}}
}{
  \beta' + \alpha' \beta' + 1
}\\
\beta' &= \frac{\rho_{\mathrm{m}}}{\rho_{\mathrm{as}}} \frac{D'_{\mathrm{m}}}{D'_{\mathrm{as}}} \frac{\Delta z_{\mathrm{as}}}{\delta} \frac{1}{\psi}
\end{aligned}
$${#eq:Y_ms}

を得る．ここまで，$\omega$を出発点として話を進めてきたが，一般的にはここでの$D'$が物理拡散係数のデータとして与えられていると考えるべきである．そのうえで$\omega$などに変換する必要があれば，都度微分係数を変換していくことになる．空気ー水蒸気系の二成分拡散係数はMarrero and Masonが経験式としてまとめている．すなわち

$$
D_{v,a} = 1.87 \times 10^{-10} \frac{T^{2.072}}{p_{\mathrm{tot}}}
$${#eq:D'_in_air}
である．ただし，本経験式において圧力$p$の単位は[atm]，温度の単位は[K]であることに注意する．また，本経験式の適用範囲は$280 \; \mathrm{K} < T < 450 \; \mathrm{K}$である[@Kreith1999-od]．この値を$D'_{\mathrm{a}}$として利用する．

## 重要な物理量の推定
### 熱伝達係数$\alpha_\mathrm{h}$
熱伝達係数は一般に運転条件や流路形状，材料特性，境界条件，流れの発達状況など複雑な要素が絡み合っているため，ある特定の値を得ることは難しい．しかしながら，その重要性から種々の経験式が提案されており，Nu数を用いた形で表されている．Nu数は

$$
\mathrm{Nu} = \frac{\alpha_{\mathrm{h}} d_{\mathrm{e}}}{\lambda}
$${#eq:Nusselt_number}

である．ここで$d_{\mathrm{e}}$は流路有効径（代表長さ）である．Nu数の経験式は[@Rohsenow1998-gx]によくまとめられている．このNu数から$\alpha_{\mathrm{h}}=\mathrm{Nu} \lambda / d_{\mathrm{e}}$として$\alpha_{\mathrm{h}}$を求める．Fluentにおいては、通常、残差が収束するように[@eq:eq:energy_conservation]で示したエネルギー方程式が解かれ、その結果として$\alpha_{\mathrm{h}}$やNu数を出力できる．そのため、境界条件として等温や等熱流束を設定した場合にこれらを与えることはない（ただし、境界条件で『Convection』を選択した場合は熱伝達率を直接入力する）．しかしながら，計算結果を代表的なNu数の理論値や相関式と比較することは、計算結果の妥当性を判断する上で非常に有効な手段である．以下，全熱交換に関連が強い代表的なNu数を紹介する．

#### 平板間，長方形ダクト，同心円管ダクトにおける層流
十分に発達した流れにおいて，等温かつ両平板の温度が等しい時$Nu= 7.54$，両平板の温度が異なる時$Nu = 4$である．Zhangら[@Zhang2008-sa]は$Nu = 7.54$を採用している．
一方，等熱流束条件かつ両平板における熱流束が等しい場合は$Nu = 8.235$である．ただし，いずれの場合も管表面における粘性散逸は無視している．また，この流路形状において平板間距離を$a$とすれば$d_{\mathrm{e}} = 2a$である．全熱交換エレメント内の流路が十分に薄く長い場合は流れの大部分が十分に発達しているとみなせるため，この値を採用できる．

#### Hausenの式とSiedel-Tateの式[@Zhang1999-iz]
上記のNu数は十分に発達した流れを前提としていた．一方，助走区間も考慮に入れる場合，Re数，Pr数も考慮に入れる必要が出てくる．ここで

$$
Re = \frac{u d_{\mathrm{e}}}{\nu}
$${#eq:Reynolds_number}

$$
Pr = \frac{\mu c_{\mathrm{p}}}{\lambda}
$${#eq:Prandtl_number}

である．ただし，$\nu$は動粘性係数（kinematic viscosity），$\mu$は粘性係数（dynamic viscosity），$c_{\mathrm{p}}$は比熱である．また，流路長さを$L$として用いて，$Re Pr d_{\mathrm{e}} / L$を考える．このパラメータは温度境界層の発達状況を示すものであり，十分に小さい場合は発達流であり，大きい場合は入口効果が支配的ということを示す．Hausenの式は層流かつ$Re Pr d_{\mathrm{e}} / L<100$程度で有効であり，Siedel-Tateの式は層流かつ$Re Pr d_{\mathrm{e}} / L \gg 100$で有効である．Hausenの式とSiedel-Tateの式はそれぞれ

$$
Nu = 3.658 + \frac{0.085 Re Pr d_{\mathrm{e}} / L}{1+0.047\left( Re Pr d_{\mathrm{e}} / L \right)^{0.67}}
\left( \frac{\mu_{\mathrm{b}}}{\mu_{\mathrm{s}}} \right) ^ {0.14}
$${eq:hausen_eq}

$$
Nu = 1.86\left( Re Pr d_{\mathrm{e}} / L \right)^{0.33}
\left( \frac{\mu_{\mathrm{b}}}{\mu_{\mathrm{s}}} \right) ^ {0.14}
$${eq:siedel_tate_eq}

である．ただし粘性係数の添え字は$\mathrm{b}$がバルク部，$\mathrm{s}$が表面近傍を示す．おそらくバルク部と膜表面部の温度の違いが粘性係数に反映されると思われるが，熱交換エレメントにおいては温度差はせいぜい10度程度であることから粘性係数の補正項は1に近似できると思われる．流れが発達するにつれて局所的な$Re Pr d_{\mathrm{e}} / x$は徐々に小さくなる．十分に発達した，すなわち$Re Pr d_{\mathrm{e}} / x \ll 1$において，等温境界条件では$Nu = 3.658$，等熱流束境界条件において$Nu = 4.364$に漸近することが知られている．
なお，Hausenの式とSiedel-Tateの式は主に円管流れに対して用いられる．長方形ダクトにおいて，高さを$B$，幅を$H$とすれば代表長さとして$d_{\mathrm{e}}=4BH/2(B+H)$を用いる．ただし，アスペクト比が大きく平行平板間流れに近い薄い長方形流路では，十分発達層流のNu数は円管の値ではなく，平行平板流れに対する値に近づくと考えらえる．そのため，全熱交換エレメントの流路が十分に薄く長い場合には，境界条件に応じて$Nu=7.54$や$Nu=8.235$などを用いる方が適切な場合がある．

## 膜の性能評価について
上記理論からモデル化のために測定が必要な物理量は以下のとおりである．

1. Sorption curve: 膜近傍空気の相対湿度$\phi$と膜内吸湿量$\theta$を結ぶ最重要な曲線．本曲線における温度や圧力の影響は調査が必要だが，$\phi$に温度依存性がある以上，WP1で定義される運転条件ごとに曲線を取得することが望ましい．

2. 膜内水分拡散係数$D'_\mathrm{m}$：一般に拡散係数は温度や含水量の関数であるが，定数として扱われることが多い．温度や含水量の影響については調査が必要である．測定において$D'_{\mathrm{m}}$単体の測定が難しい場合，膜全体としての透湿性能を測定するのでも十分である．これはおそらく測定方法によるが，$r_{\mathrm{m}}$，$r'_{\mathrm{m}}$，$\rho_{\mathrm{m}} D_{\mathrm{m}}$，$\rho_{\mathrm{m}} D'_{\mathrm{m}}$のいずれかに対応するものである．

3. 膜厚$\delta$：$\delta$は$r_{\mathrm{m}}$に一次の影響を与えるため，この誤差がそのまま膜抵抗の誤差としてのることになる．$\delta$は一般に10μm程度のオーダーであり，厳密な測定が必要となる．また，乾燥時と吸湿時でどの程度変化するかを確認する．

4. 膜密度$\rho_{\mathrm{m}}$：乾燥状態の見かけ密度を測定する．見かけ密度は空隙も含んだ値であり，素材そのものの質量よりも小さくなる．これに素材そのものの密度を考慮することで空隙率も得ることができる．

5. 熱伝導率$k_{\mathrm{m}}$：膜の顕熱移動を表す熱伝導率を測定する．ただし，この測定の重要性は低い．総括熱抵抗は空気から膜への熱伝達率とこの熱伝導率の両者を考慮されるが，一般に膜熱伝導率が総括熱抵抗に与える影響は小さく，例えば紙から金属などに変更したとしても5\%程度しか改善されないとされている．そのため，膜間の顕熱交換で支配的な要素は熱伝達率であり，熱伝導率は補助的である[@undated-uj]．

## Fluentにおける注意点
### 膜近傍の刻み幅
本モデルにおいて，膜近傍における熱と物質輸送が非常に重要であることは自明である．すなわち，膜近傍における温度・速度・濃度（または水蒸気質量分率）境界層を適切に解像しないと計算精度が悪化する．このことはLiu[@Liu2025-mz]らも述べており，膜が十分に薄いという条件において，少なくとも膜法線方向に膜厚以下に刻み幅をとることが推奨されている．

### CMDRの計算
UDFでCMDRを計算するにあたって，[@eq:CMDR]をそのままコーディングするとエラーの恐れがある．というのも，湿度が低い時，特に計算初期において$$\phi \approx 0$の場合，$C/\phi$が発散し，CMDRも発散してしまう．そこで式変形して


$$
\psi = \frac{\left( (1-C) \phi +C \right)^2}
  {A w_{\mathrm{max}} C}
$${#eq:CMDR_rev}

とする．これにより発散の可能性を減らすことができる．加えて，初期状態では流体に湿度が定義されておらず，流入してくる湿気空気がドメイン全体に広がるまで収束を待つ必要がある．発散を防ぐという面でも，収束を早めるという面でも，初期条件として流体に流入条件と同様の温度と湿度をパッチすることが有効と考えられる．

# スケジュール
## WP2：2026年6月1日から2026年11月30日まで
WP2ではFormFlex HXを用いたプロトタイプを製作し，分析・測定を行う．測定自体はルツェルン応用大学で行う．このプロトタイプは現行品をFormFlex HXに置き換えたものであり，二次元的なものである．既存のCADや材料，製造情報をまとめる必要がある．

# 疑問
## 調査項目
* 従来のmenbraneで圧力差によって変形しやすいとはどれくらいの圧力差か？
* 熱交換機において熱交換効率はどのように定義されるか？また，一般的な効率はどの程度で，理論上可能な最大の交換効率はどの程度か？
* FormFlex HXの特許はどこが先進的か？
* 従来の膜はどのような素材であり，なぜ変形しやすいか？一方，FormFlex HXはなぜ変形しないか？また，最小曲げ半径や許容引張り・曲げ応力はどの程度か？製造・成型方法は？
* 各国における環境規制が本クライアントの市場制圧において重要そう．EUにおけるErP指令とは？北米におけるASHRAE90.1とは？その他，NYCECC，RLT装置に対する73%効率要求とは？
* FormFlex HXは細菌やウイルスを通さないとあるが，それはどの膜もそうなのでは？逆に熱以外に何を通す？
* 現在の空調市場では熱交換器のほうがエンタルピー交換器よりも優勢らしい．どれくらいの市場レンジなのか？

## Mariusに聞くこと
* ZHAW側のチームメンバーは誰か？Marius, Cristian, Masayaであってるか？また，これまでは昌弥はMariusのもとで仕事していたがこのプロジェクトでもそうか？それともCristianの指示の下で進めるか？
* Proposalを読んでいるが，ZHAWの中での役割分担まではわからない．これは今後ZHAW内で週例MTGをしたりするのか？
* とりあえず今週と来週は先行研究調査に使おうと思うが大丈夫か？それともCristianに指示を仰いだ方がいいか？これまで一人で進めていたので，今回どれだけチームで協力する体制になるのかわからないことが不安．
* プロジェクトのフォルダが見つからなかった．まだ作成されていないのかそれともいつもとは違うディレクトリにあるのか？
* まずは5点の作動点の決定が重要という印象を受けた．これについてはPolyblockが指示してくるのか，それもとZHAWからも提案するのか？

# Polyblock AG社について
1982年創業の熱交換器，エンタルピー交換器，排熱回収器などを扱うメーカー．Winterthurに拠点を置き，これらの機械及び関連部品の製造を行っている．対象はビル，病院，学校，集合住宅，向上などに向けた空調システムや排熱・CO2回収などである．最初はガレージ発のスタートアップらしい．現坐剤の従業員数は正確な値はわからないが数十人規模と推定される．

# ここまでの作業メモ
以下、**昨日から今日までの作業ログ兼・来週再開用メモ**として整理します。

---

# 膜式全熱交換器 Fluent UDF デバッグまとめ

対象：水蒸気 mass flux UDF、全抵抗モデル、relaxation factor、収束安定化

## 1. 最初の問題意識

当初、膜境界で水蒸気移動をUDFで与えたところ、`continuity residual` が大きく跳ね、高温側・低温側の `Y_H2O` が非物理的に大きく変化した。

特に、初期条件として

```text
hot side  : Y_H2O ≈ 0.0206
cold side : Y_H2O ≈ 0.0117
```

を与えているにもかかわらず、計算後に

```text
Y_H2O = 0.1 以上
```

のような値が膜近傍で出た。

まず疑ったことは、

```text
1. H2O mass fraction の入力ミス
2. species mass flux の符号規約ミス
3. psi / beta / y_mem の NaN
4. dz が小さすぎることによる過大flux
5. heat generationなしによるエネルギー不整合
6. 離散化・pseudo time・初期流れ場の影響
```

だった。

---

## 2. 入力条件と物性値の確認

温湿度条件から、空気中の水蒸気質量分率を再計算した。

```text
27°C, RH 54%  → Y_H2O ≈ 0.0119
35°C, RH 59%  → Y_H2O ≈ 0.0206
```

したがって、hot側 `Y_H2O ≈ 0.02`、cold側 `Y_H2O ≈ 0.0117` は妥当。

一時は `0.02` と入れるべきところを `0.2` と入力した可能性を疑ったが、確認したところ入力は正しく `0.02` だった。

また、Operating Pressure は Fluent 側で

```text
Operating Pressure = 101325 Pa
```

になっていることを確認した。UDF内で

```c
C_P(c, t) + RP_Get_Real("operating-pressure")
```

として絶対圧に変換している方針は妥当。

---

## 3. species mass flux の符号規約

GUIで `wall-28` と `wall-28-shadow` の mass flux 符号を確認した結果、当初想定していた

```text
positive = outward from fluid domain
```

ではなく、実際には boundary condition としては

```text
positive = into fluid domain
```

として扱う必要があると判断した。

したがって、物理フラックスを

```text
j > 0 : hot → membrane → cold
```

と定義すると、Fluentに渡す値は、

```text
cold side wall-28        : +j
hot side wall-28-shadow : -j
```

である。

UDF内では現在、

```c
j_h = - (Y_h - Y_c) / R_tot;
j_c =   (Y_h - Y_c) / R_tot;
```

としており、この符号は現在の理解では正しい。

---

## 4. NaN問題と psi の式変形

初期のCSV出力で、一部faceにおいて

```text
y_mem_h = NaN
y_mem_c = NaN
psi     = NaN
beta    = NaN
```

が発生した。

原因は、相対湿度 `phi` がゼロ近傍になったとき、CMDR式の中に

```text
C / phi
```

のような項があり、`phi = 0` で発散していたこと。

これを、

```text
(1 - C) * phi + C
```

の形に式変形し、分母に `phi` が来ない形にしたことで NaN は解消した。

現在の CMDR は概ね以下：

```c
term = (1.0 - C_mem) * phi + C_mem;
psi = 1.0e6 * term * term / exp(5294.0 / T) / W_max / C_mem;
```

---

## 5. 旧モデル：dzベースの膜面flux

当初のモデルでは、膜面近傍セルと膜表面値の差から、

```text
j_h = rho_h D_h (Y_h - Y_mem_h) / dz_h
j_c = -rho_c D_c (Y_mem_c - Y_c) / dz_c
```

としていた。

ここで `dz` は膜面face中心から隣接セル中心までの距離。

確認したところ、

```text
dz ≈ 5e-6 m
```

だった。

当初は 2 mm を100分割しているのでセル高さ20 µm、壁面から中心まで10 µmのはずと考えたが、実際には片側流路が1 mm/100分割相当になっているか、実メッシュ上で第1セル中心距離が5 µmになっている可能性が高いと判断した。

この場合、

```text
rho D / dz ≈ 1 * 2.6e-5 / 5e-6 ≈ 5.2 kg/m2/s
```

となり、`ΔY = 0.01` 程度でも

```text
j ≈ 0.05 kg/m2/s
```

が出る。実際、旧モデルでは局所的に

```text
j = E-2〜E-1 kg/m2/s
```

が発生し、これが `Y_H2O` の急上昇と収束悪化の主因と判断した。

---

## 6. relaxation factor の導入

旧モデルでは、fluxが強すぎるため、まず数値安定化として relaxation factor を導入した。

```c
j_used = FLUX_RELAX * j_model;
```

旧モデルでは、

```text
FLUX_RELAX = 0.001 → 安定
FLUX_RELAX = 0.01  → 安定
FLUX_RELAX = 0.1   → ある程度安定
FLUX_RELAX = 1.0   → residuals高止まり、不安定
```

だった。

この時点で、

```text
relaxation factor は物理係数ではなく、数値安定化・continuation用
```

と整理した。

---

## 7. 物理モデル改善：Sh/Nu/Leベースの全抵抗モデル

`dz` に強く依存する旧モデルをやめ、物理的な境界層抵抗を入れるため、全抵抗モデルへ移行した。

現在の基本式は、

```text
j = (Y_h - Y_c) / R_tot
```

ここで、

```text
R_tot = R_h + R_m + R_c
```

各抵抗は、

```text
R_h = 1 / (rho_h h_m,h)
R_c = 1 / (rho_c h_m,c)
R_m = psi delta_mem / (rho_mem D_mem)
```

物質伝達係数は、

```text
Sh = Nu Le^(-1/3)
h_m = Sh D_v / d_h
```

としている。

UDFでは現在、

```c
Sh = Nu * pow(Le, -1.0/3.0);
k  = D_v * Sh / 2 / delta_channel;
```

としている。これは、

```text
d_h = 2 * delta_channel
```

と解釈するならOK。`delta_channel = 2 mm` をすでに水力直径として使うならここは修正が必要。

現在の代表値では、

```text
R_h, R_c ≈ E1
R_m      ≈ E2
```

であり、膜抵抗支配になっている。これは物理的には不自然ではない。

---

## 8. 最新UDFの状態

最新の `BC_membrane_rev1(7).c` では、mass transfer部分は全抵抗モデルに更新されている。CSV出力もBCと同じ式を使うように統合した。

現在のmass flux本体は概ねOK。

```c
R_tot = func_total_mass_transfer_resistance(rho_h, rho_c, k_h, k_c, psi);

j_h = - (y_h2o_h - y_h2o_c) / R_tot;
j_c =   (y_h2o_h - y_h2o_c) / R_tot;
```

ただし、来週再開時に注意すること：

```text
1. コメントがまだ古い
   positive flux is outward from each fluid domain
   と書かれているが、実装は positive = into fluid domain

2. heat generation側は旧モデルのまま
   mass transferと不整合なので、まだhookしない方がよい

3. export_wall_face_zone は現在 wall-28 出力専用に近い
   wall-28-shadowも出力するならhot/cold対応分岐を戻す

4. コメントに全角ピリオドが残っている可能性
   Fluent compileで文字コード問題になるなら削除する
```

---

## 9. 全抵抗モデルでの計算結果

全抵抗モデル導入後、明らかに旧モデルより安定した。

特に、

```text
旧モデル：relaxation 0.3以上で崩れやすい
全抵抗モデル：relaxation 0.1〜0.3なら比較的安定
```

となった。

ただし、relaxationなし、または高い係数ではまだ膜近傍の `Y_H2O` が大きく変化する。

1 iterationだけでは、

```text
hot側 Y_H2O は下がる方向
cold側 Y_H2O は上がる方向
```

であり、方向性は正しい。

しかし10 iteration程度回すと、条件によっては

```text
cold側 Y_H2O が 0.1以上
hot側 Y_H2O も 0.05程度
```

まで上がるケースがあり、まだfluxが局所セルに対して強い可能性がある。

---

## 10. relaxation factor の再評価：全抵抗モデル版

全抵抗モデルで、

```text
relaxation = 0.1 : 安定
relaxation = 0.3 : 安定
relaxation = 0.5 : residuals悪化
```

という結果になった。

0.5にすると、

```text
continuity が上昇
h2o residual も上昇
velocity / energy もじわじわ悪化
```

した。

このため、現状では

```text
0.3 が実用上の上限候補
```

と考えている。

来週試すなら、

```text
0.30 → 0.35 → 0.40 → 0.45 → 0.50
```

のように細かく刻む価値はある。

---

## 11. 離散化条件の検討

当初の離散化は、

```text
Pressure-Velocity Coupling : Coupled
Pressure                   : Second Order
Density                    : Second Order Upwind
Momentum                   : Second Order Upwind
h2o                        : Second Order Upwind
Energy                     : Second Order Upwind
Pseudo Time Method          : Global Time Step または Off
```

で試した。

h2oの局所的な振動・オーバーシュートを疑い、

```text
h2o : First Order Upwind
```

も試したが、0.5での不安定化にはあまり改善が見られなかった。

この結果から、

```text
主因は高次離散化によるspeciesオーバーシュートではなく、
膜面mass fluxと流れ場・密度場の連成の強さ
```

と判断した。

---

## 12. Pseudo Time Method の検討

Pseudo Time Methodは、定常計算に仮想的な時間項を加えて安定に定常解へ近づける方法。

試したこと：

```text
Pseudo Time = Local Time
```

しかし、あまり改善は見られなかった。

したがって、

```text
pseudo timeの設定だけで0.5を安定化するのは難しそう
```

と判断。

---

## 13. heat generation rate について

現時点では、heat generation rateはまだ入れていない。

理由：

```text
1. mass transfer単体の挙動を先に安定化したい
2. heat generationを同時に入れると原因切り分けが難しい
3. 現在のheat generation UDFは旧モデル由来のjを使っており、mass transferと不整合
```

ただし、物理的には水分移動には潜熱移動が伴うため、最終的には必ず必要。

将来入れる場合は、旧モデルの

```text
j_h = rho D (Y - Y_mem) / dz
```

ではなく、全抵抗モデルの

```text
j = (Y_h - Y_c) / R_tot
```

と同じ `j` を使うべき。

潜熱項は、

```text
q'' = j L_w       [W/m2]
q''' = j L_w / delta_mem  [W/m3]
```

となる。

ただし Heat Generation Rate の符号規約は species mass flux と別なので、片側ずつ検証が必要。

---

## 14. 現在の作業方針

現時点では、heat generationは一旦無視し、

```text
全抵抗モデル + relaxation factor
```

で水分移動だけを安定化する方針。

現在の暫定結論：

```text
0.1〜0.3 : 使える
0.5     : 不安定
```

次の試行として、

```text
UDFなしで流れ場を先に作る
→ その後 UDFをhook
→ 0.1 → 0.3 → 0.35 → 0.4 → ...
```

を試す予定。

---

## 15. 流れ場初期化の検討

流れ場が未発達な状態で膜mass fluxを入れると、

```text
膜面からH2Oが入る
しかし対流で運ばれない
膜近傍セルに蓄積
Y_H2Oが急上昇
continuity / density / velocityが乱れる
```

可能性がある。

そのため、次に試すべき手順：

```text
1. UDFなし、またはmass flux = 0で計算
2. 本番と同じinlet速度・温度・湿度条件でinitialize
3. 速度場・温度場・species場を100〜300 itr程度なじませる
4. case/data保存
5. UDFをhook
6. relaxation = 0.1から開始
7. 0.3 → 0.35 → 0.4 → 0.5 と刻む
```

このテストで、

```text
UDFなし予備計算後に0.5が安定する
→ 初期流れ場の影響が大きい

それでも0.5が不安定
→ 膜mass flux境界条件そのものが主因
```

と判断できる。

---

## 16. 来週再開時のおすすめ手順

来週は以下の順で再開するのがよい。

### Step 1：最新UDFの整理

```text
1. コメントの符号規約を修正
2. 全角文字を削除
3. 未使用変数を削除
4. heat generation profileはhookしない
5. mass flux profileのみhook
```

### Step 2：UDFなしでベース場作成

```text
1. mass flux UDFを外す
2. inlet条件は本番通り
3. 100〜300 itr回す
4. residualと速度場を確認
5. case/data保存
```

### Step 3：UDF hook

```text
1. h2o_membrane_mass_flux を wall-28 / wall-28-shadow 両方へhook
2. relaxation = 0.1
3. 50〜100 itr
4. CSV出力
5. Y_H2O, j, R_h, R_m, R_c, R_totを確認
```

### Step 4：relaxationを刻む

```text
0.1 → 0.2 → 0.3 → 0.35 → 0.4 → 0.45 → 0.5
```

各段階で確認するもの：

```text
continuity residual
h2o residual
Y_H2O min/max
hot outlet Y_H2O
cold outlet Y_H2O
j_c / j_h の最大・最小・平均
H2O mass balance
```

### Step 5：限界判定

```text
0.4〜0.5でも安定
→ 次はheat generation整合化へ進む

0.3以上で不安定
→ 現状は0.3を暫定採用し、モデル改善へ
```

---

# 現時点の一言まとめ

**旧dzベースモデルは硬すぎた。Sh/Nu/Leベースの全抵抗モデルにしたことで大幅に安定化した。ただし、全抵抗モデルでもrelaxation 0.5ではまだ不安定で、現状では0.3程度が実用上の安定上限。次はUDFなしで流れ場を先に作ってからUDFをhookし、0.35〜0.5を再評価する。heat generationはmass transfer単体が安定してから、全抵抗モデルの同じjを使って実装する。**
