(* ::Package:: *)

simphenyGPRr2gpr[table_]:=Module[{protHelperFunc,convertLogic,parseProteinAssociation,proteinAssociations,proteinGeneAssociations},
protHelperFunc=#/.If[AtomQ[#]&&#=!=Null,#->protein[ToString[#]],(#->protein[ToString[#]]&/@Union[Cases[#,_Symbol,\[Infinity]]])]&;
convertLogic=StringReplace[#,{"and"->"&&","or"->"||"}]&;
parseProteinAssociation=StringReplace[#[[1]],"-"->"_"]->protHelperFunc[ToExpression@convertLogic[#[[-1]]]]/.a_And:>proteinComplex@@a&;
proteinAssociations=(parseProteinAssociation/@table)/.Null->None;
proteinGeneAssociations=StringCases[#[[6]],RegularExpression["(\\w+)\\s+\\(([\\&\\s\\w]+)\\)"]:>protein["$1"]->(If[Length[#]>1,geneComplex[Sequence@@(gene[ToString[#]]&/@#)],gene@ToString[#]]&[(ToExpression[convertLogic@"$2"])])]&/@table;
Union[Flatten[{DeleteCases[proteinAssociations,r_Rule/;r[[2]]===None,\[Infinity]],Union@Flatten[proteinGeneAssociations]}]]
];


xmlReaction2geneAssociation=If[Length[#]>0,#[[1]],#]&@Cases[Cases[#[[3]],XMLElement["notes",__]][[1]],s_String/;StringMatchQ[s,RegularExpression["GENE ASSOCIATION:(.*)"]]:>ToExpression@StringReplace[s,{"GENE ASSOCIATION:"->"","or"->"||","and"->"&&"}],\[Infinity]]&;


getReferenceFluxesAndBoundsFromXML[path_String]:=Block[{tmp,tmp2,tmp3,tmp4},
tmp=Import[path,"Text"];
tmp2=StringCases[tmp,RegularExpression["(?s)listOfReactions.+"]];
tmp3=Flatten[StringSplit[tmp2,RegularExpression["<reaction id="]][[1]][[2;;]]];
tmp4=Quiet@StringCases[#,RegularExpression["(?s)^(\"R_.+?\").+\"LOWER_BOUND\"\\s*?value=\"([-\\d\\.]+)\".+?\"UPPER_BOUND\"\\s*?value=\"([\\d\\.]+)\".+?\"FLUX_VALUE\"\\s*?value=\"(.+?)\""]:>{"$1"->{ToExpression@"$2",ToExpression@"$3",ToExpression@"$4"}}]&/@tmp3;
Flatten[tmp4]/.s_String:>StringReplace[s,{"\""->""}]
];