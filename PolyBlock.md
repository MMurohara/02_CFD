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

## 水分フラックスの$\omega$による表示
本解析で最も重要になるのは膜を通過する水分のモデル化である．これから説明するモデルは2001年にJ.L. NiuおよびL.Z. Zhangによって構築され[@Niu2001-es]，その後2025年の最新論文[@Liu2025-mz]に至るまで採用されている．本モデルにおいて，空気中の絶対湿度$\omega$，空気中の相対湿度$\phi$および膜中の絶対湿度$\theta$の三つの水分表示が出てくる．それぞれの定義式は以下のとおりである．

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
モデル化にあたって，以下を仮定する．

1. 流れ平面方向の水分子の移動は無視する．これは参考文献[@Niu2001-es]の計算結果による．運転条件によってはこの過程が崩れることもあるため，Pe数が2以上であることを確認すること．

2. 膜の吸湿は平衡状態である．

3. 膜における水分の拡散係数$D_{\mathrm{m}}$は定数である．

4. 吸湿，脱湿時の吸熱・放熱は定数であり，両者等しい値である．

まず膜の吸湿は平衡状態であることから，供給側空気から膜へのフラックス$j_{\mathrm{s}}$，膜内でのフラックス$j_{\mathrm{m}}$および膜から排気側空気へのフラックス$j_{\mathrm{e}}$は等しい．すなわち

$$
j_{\mathrm{s}} = j_{\mathrm{m}} = j_{\mathrm{e}}
$${#eq:flux_equ}

である．ここで，フラックスの単位は$[\mathrm{kg \; m^{-2} \; s^{-1}}]$である．空気中における水分フラックス$j_{\mathrm{s}}$および$j_{\mathrm{e}}$は吸気側，排気側に関わらずフィックの法則で表される．すなわち

$$
j_{\mathrm{s}} =j_{\mathrm{e}} = - \rho_{\mathrm{a}} D_{\mathrm{a}} \frac{\partial \omega}{\partial z}
$${#eq:fick_law}

である．ここで，$D$は$\omega$に対する拡散係数[$\mathrm{m^2 \; s^{-1}}$]であり，後述の$Y$への変換では異なる値になることに注意する．
次に膜内のフラックス$j_{\mathrm{m}}$を考える．これを考えるにあたって，膜近傍空気の$\omega$と膜表面の$\theta$との関係を求める必要がある．この$\theta$は膜材料特性や湿度に強く依存し，実験的に求める必要がある．例えばVapor absorption analyzer - Hydrosorb-1000[@Zhang2008-sa]などの分析器を用いる．この分析により，sorption curve（吸着等温線）を取得する．sorption cuveは横軸に相対湿度$\phi$をとり，縦軸に膜の絶対湿度$\theta$をとり，以下の式で表現される．

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
\psi = \left(A\frac{\partial \theta}{\partial \phi} \right)^{-1}
$${#eq:CMDR}

として表す．ただし，ここでの$A$や$\phi$は供給空気側の値を用いる．$\rho_{\mathrm{m}}D_{\mathrm{m}}$をまとめて透湿係数$K [\mathrm{kg \; m^{-1} \; s^{-1}}]$として扱うこともある．詳細は参考文献[@Niu2001-es]を参照のこと．ここで$\psi$はcoefficient of moisture diffusive resistanceと呼ばれる．式[@eq:phi_to_omega]を用いればこのCMDRは

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
Y_{\mathrm{me}} = Y_{\mathrm{ae}} + \alpha \left( 
  Y_{\mathrm{as}} - Y_{\mathrm{ms}}
\right)\\
\alpha' = \frac{\rho_{\mathrm{as}}}{\rho_{\mathrm{ae}}} \frac{D'_{\mathrm{as}}}{D'_{\mathrm{ae}}} \frac{\Delta z_{\mathrm{ae}}}{\Delta z_{\mathrm{as}}}
$${#eq:Y_me}

および

$$
Y_{\mathrm{ms}} =\frac{
  \beta Y_{\mathrm{ae}} + (\alpha \beta  + 1)Y_{\mathrm{as}}
}{
  \beta + \alpha \beta + 1
}\\
\beta' = \frac{\rho_{\mathrm{m}}}{\rho_{\mathrm{as}}} \frac{D'_{\mathrm{m}}}{D'_{\mathrm{as}}} \frac{\Delta z_{\mathrm{as}}}{\delta} \frac{1}{\psi}
$${#eq:Y_ms}

を得る．ここまで，$\omega$を出発点として話を進めてきたが，一般的にはここでの$D'$が物理拡散係数のデータとして与えられていると考えるべきである．そのうえで$\omega$などに変換する必要があれば，都度微分係数を変換していくことになる．

## 膜の性能評価について
上記理論からモデル化のために測定が必要な物理量は以下のとおりである．

1. Sorption curve: 膜近傍空気の相対湿度$\phi$と膜内吸湿量$\theta$を結ぶ最重要な曲線．本曲線における温度や圧力の影響は調査が必要だが，$\phi$に温度依存性がある以上，WP1で定義される運転条件ごとに曲線を取得することが望ましい．

2. 膜内水分拡散係数$D'_\mathrm{m}$：一般に拡散係数は温度や含水量の関数であるが，定数として扱われることが多い．温度や含水量の影響については調査が必要である．測定において$D'_{\mathrm{m}}$単体の測定が難しい場合，膜全体としての透湿性能を測定するのでも十分である．これはおそらく測定方法によるが，$r_{\mathrm{m}}$，$r'_{\mathrm{m}}$，$\rho_{\mathrm{m}} D_{\mathrm{m}}$，$\rho_{\mathrm{m}} D'_{\mathrm{m}}$のいずれかに対応するものである．

3. 膜厚$\delta$：$\delta$は$r_{\mathrm{m}}$に一次の影響を与えるため，この誤差がそのまま膜抵抗の誤差としてのることになる．$\delta$は一般に10μm程度のオーダーであり，厳密な測定が必要となる．また，乾燥時と吸湿時でどの程度変化するかを確認する．

4. 膜密度$\rho_{\mathrm{m}}$：乾燥状態の見かけ密度を測定する．見かけ密度は空隙も含んだ値であり，素材そのものの質量よりも小さくなる．これに素材そのものの密度を考慮することで空隙率も得ることができる．

5. 熱伝導率$k_{\mathrm{m}}$：膜の顕熱移動を表す熱伝導率を測定する．ただし，この測定の重要性は低い．総括熱抵抗は空気から膜への熱伝達率とこの熱伝導率の両者を考慮されるが，一般に膜熱伝導率が総括熱抵抗に与える影響は小さく，例えば紙から金属などに変更したとしても5\%程度しか改善されないとされている．そのため，膜間の顕熱交換で支配的な要素は熱伝達率であり，熱伝導率は補助的である[@undated-uj]．


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