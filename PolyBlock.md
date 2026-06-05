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

# 全熱交換器一般
## quasi-counter flow

# 理論
## 交換効率
顕熱は温度交換効率，潜熱は湿度交換効率によって定義される．[@fig:POL_flow_schematics]のように各流れを定義する．ただし，各略語は以下の通りである．

* OA: Outer Air．屋外から全熱交換器へと送られる空気
* SA：Supply Air．全熱交換器を経て室内へ供給される空気
* RA：Return Air．室内から全熱交換器へと送られる空気
* EA：Exhausted Air．全熱交換器を経て室外へと排出される空気

![Shematic of a enthalpy exchanger element (corrugate/ cross flow) .](img/POL_flow_schematics.png){#fig:POL_flow_schematics}

温度を$\theta$，湿度を$\omega$で表せば，それぞれの交換効率$\eta_{\mathrm{t}}$および$\eta_{\mathrm{h}}$は以下のように表せる．

$$
\eta_{\mathrm{t}} = \frac{\theta_{\mathrm{OA}} - \theta_{\mathrm{SA}}}
{\theta_{\mathrm{OA}} - \theta_{\mathrm{RA}}}
$${#eq:temperature_exchange_eff}

$$
\eta_{\mathrm{h}} = \frac{\omega_{\mathrm{OA}} - \omega_{\mathrm{SA}}}
{\omega_{\mathrm{OA}} - \omega_{\mathrm{RA}}}
$${#eq:humid_exchange_eff}

## 支配方程式


## 膜の性能評価について

# Fluentを用いた数値解析方法
## 多孔質中の水分移動
2013年時点で「多孔質中の水分移動についてうまく計算できない．そのため，研究者ごとにコードを自作したり，UDFでFluentを回している．」という記述がみられる[@Al-Waked2013-nv]．Fluentにおいて多孔質における流体領域は当時でも水蒸気移動（単なる移流拡散）は標準サポートされていたようなので，多孔質材のうち固体部分で吸着・拡散する水蒸気の取り扱いの話をしていると考えられる．[@Liu2025-mz]においても，2024R1のバージョンでも膜内での質量移動モデルを取り扱っておらず，UDFを用いたとの記述がある．

### Al-Wake (2013)[@Al-Waked2013-nv]らの仮定
Al-Wakedらの論文では水分移動についてかなりの簡略化がなされている．すなわち
* Steady state processes of heat and mass transfer.
* The adsorption of water vapour on and from the membrane is in a dynamic equilibrium state.
* Constant and equal heat of vaporisation and heat of sorption. 
* Constant and isotropic heat and mass transfer resistance through the membrane. According to Min et al. [11,12,22], heat transfer resistance is function of latent-to-sensible heat ratio. This is because the adsorption heat at the membrane surface also transfers across the membrane. However, they concluded that the thermal resistance accounts for a small fraction of the total thermal resistance and can be ignored. Furthermore, the mass transfer resistance is strongly affected by membrane properties and operating conditions [1,11,12,18,19,22–24,26]. Due to validation requirements with Zhang [20], the mass transfer resistance is considered constant.
* The Reynolds number (Re = qvD /l ) at the inlet of the flow pas- sage was found to be less than 1000; therefore, the flow is assumed to be of laminar nature [20]. The hydraulic diameter (D
h) is approximated to be (2  passage height = 8 mm) [1]. The value of Reynolds number inside the quasi heat exchanger is expected be even lower due to the expansion the cross-sec- tion of the flow passage.
である．つまり水分移動の係数を定数と扱い，膜自体の温度や吸湿量などは考慮していない．平衡状態を解いているという仮定から正当化されるものと考えられる．しかし，どの値をとるかは本来作動条件に依存するので，本プロジェクトのような複数の作動点を考える場合はそれぞれで適切な係数を定める必要がある．できればこの係数に温度や流量などの条件を入れ込みたい．これらの係数はおそらくHSLUでの試験で測定されることになるので支配方程式の中でどの係数がどの程度詳細に測定される必要があるかを決定する．
また，本論文中で重要な点として，膜を単なる境界壁として扱っているようである．膜自体は薄いために一次元拡散として解き，わざわざメッシュを切らずにUDF内での取り扱いに限定している．これは最初の計算としては良さそうだが，将来的にFormFlex HXで曲面膜を考えるとなったときにどう扱うかは問題になりそう．
水分移動は基本的には膜間の湿度差または湿度比によって駆動される．どちらが採用されるべきかは調査が必要である．

## 膜内の熱・物質移動
膜は厚みが大きくても100μm程度であり，十分に薄い．膜内の熱・物質移動は等方的と仮定すれば，膜厚が非常に薄いため厚み方向一次元に簡略化される．すなわち，膜内温度$T_{\mathrm{m}}$と膜内水濃度$Y_{\mathrm{v,m}}$について

$$
\frac{\partial^2 T_{\mathrm{m}}}{\partial z^2} = 0
$${#eq:one_dim_temperature}

$$
\frac{\partial^2 Y_{\mathrm{v, m}}}{\partial z^2} = 0
$${#eq:one_dim_vapor_concentration}

である．

## 膜表面での熱・物質移動
低温側・高温側の膜表面における水濃度$Y_{\mathrm{v, mc}}$および$Y_{\mathrm{v, mh}}$はそれぞれ

$$
Y_{\mathrm{v, mc}} = Y_{\mathrm{v, cs}} + a_1 \left( 
  Y_{\mathrm{v, hs}} - Y_{\mathrm{v, mh}}
\right)
$${#eq:Y_v_mc}

$$
Y_{\mathrm{v, mh}} = \frac{
  Y_{\mathrm{v, cs}} + \left( a_1 + a_2 \right) Y_{\mathrm{v, hs}}
}
{a_1 + a_2 + 1}
$${#eq:Y_v_mh}
として求められる．ただし，

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