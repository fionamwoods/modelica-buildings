within Buildings.Controls.OBC.ASHRAE.PrimarySystem.ChillerPlant.Staging.Processes;
block Up "Sequence for control devices when there is stage-up command"

  parameter Integer nChi=2 "Total number of chillers in the plant";
  parameter Integer nSta=3
    "Total stages, zero stage should be seem as one stage";
  parameter Boolean haveWSE=true
    "Flag of waterside economizer: true=have WSE, false=no WSE";
  parameter Boolean havePonChi=false
    "Flag to indicate if there is pony chiller"
    annotation (Dialog(tab="Pony chiller"));
  parameter Integer upOnOffSta=0
    "Index of stage when staging up to the stage, need to turn off small chiller. When no stage chang need the change, set it to zeros"
    annotation (Dialog(tab="Pony chiller", enable=havePonChi));
  parameter Integer dowOnOffSta=0
    "Index of stage when staging down to the stage, need to turn on small chiller. When no stage chang need the change, set it to zeros"
    annotation (Dialog(tab="Pony chiller", enable=havePonChi));
  parameter Real chiDemRedFac=0.75
    "Demand reducing factor of current operating chillers"
    annotation (Dialog(group="Chiller demand limit"));
  parameter Modelica.SIunits.Time holChiDemTim=300
    "Time of actual demand less than center percentage of currnet load"
    annotation (Dialog(group="Chiller demand limit"));
  parameter Modelica.SIunits.Time byPasSetTim=300
    "Time to reset minimum by-pass flow"
    annotation (Dialog(group="Reset minimum bypass"));
  parameter Modelica.SIunits.VolumeFlowRate minFloSet[nSta]={0,0.0089,0.0177}
    "Minimum flow rate at each chiller stage"
    annotation (Dialog(group="Reset minimum bypass"));
  parameter Modelica.SIunits.Time aftByPasSetTim=60
    annotation (Dialog(group="Reset minimum bypass"));
  parameter Modelica.SIunits.VolumeFlowRate minFloDif=0.01
    "Minimum flow rate difference to check if bybass flow achieves setpoint"
    annotation (Dialog(group="Reset minimum bypass"));
  parameter Boolean isHeadered=true
    "Flag of headered condenser water pumps design: true=headered, false=dedicated"
    annotation (Dialog(group="Enable condenser water pump"));
  parameter Real chiNum[nSta]={0,1,2}
    "Total number of operating chillers at each stage"
    annotation (Dialog(group="Enable condenser water pump"));
  parameter Real uLow=0.005 "if y=true and u<uLow, switch to y=false"
    annotation (Dialog(group="Enable condenser water pump"));
  parameter Real uHigh=0.015 "if y=false and u>uHigh, switch to y=true"
    annotation (Dialog(group="Enable condenser water pump"));
  parameter Modelica.SIunits.Time thrTimEnb=10
    "Threshold time to enable head pressure control after condenser water pump being reset"
    annotation (Dialog(group="Enable head pressure control"));
  parameter Modelica.SIunits.Time waiTim=30
    "Waiting time after enabling next head pressure control"
    annotation (Dialog(group="Enable head pressure control"));
  parameter Boolean heaStaCha=true
    "Flag to indicate if next head pressure control should be ON or OFF: true = in stage-up process"
    annotation (Dialog(group="Enable head pressure control"));
  parameter Modelica.SIunits.Time chaChiWatIsoTim=300
    "Time to slowly change isolation valve"
    annotation (Dialog(group="Enable CHW isolation valve"));
  parameter Real iniValPos=0
    "Initial valve position, if it is in stage-up process, the value should be 0"
    annotation (Dialog(group="Enable CHW isolation valve"));
  parameter Real endValPos=1
    "Ending valve position, if it is in stage-up process, the value should be 1"
    annotation (Dialog(group="Enable CHW isolation valve"));
  parameter Modelica.SIunits.Time proOnTim=300
    "Threshold time to check if newly enabled chiller being operated by more than 5 minutes"
    annotation (Dialog(group="Enable next chiller"));

  Buildings.Controls.OBC.CDL.Interfaces.IntegerInput uChiPri[nChi]
    "Chiller enabling priority"
    annotation (Placement(transformation(extent={{-280,230},{-240,270}}),
      iconTransformation(extent={{-240,200},{-200,240}})));
  Buildings.Controls.OBC.CDL.Interfaces.BooleanInput uStaUp
    "Stage up status: true=stage-up"
    annotation (Placement(transformation(extent={{-280,190},{-240,230}}),
      iconTransformation(extent={{-240,160},{-200,200}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput uChiLoa[nChi](
    each final quantity="HeatFlowRate",
    each final unit="W")
    "Current chiller load"
    annotation (Placement(transformation(extent={{-280,150},{-240,190}}),
      iconTransformation(extent={{-240,120},{-200,160}})));
  Buildings.Controls.OBC.CDL.Interfaces.BooleanInput uChi[nChi]
    "Chiller status: true=ON"
    annotation (Placement(transformation(extent={{-280,110},{-240,150}}),
      iconTransformation(extent={{-240,80},{-200,120}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput VChiWat_flow(final unit=
        "m3/s") "Measured chilled water flow rate" annotation (Placement(
        transformation(extent={{-280,80},{-240,120}}), iconTransformation(
          extent={{-240,40},{-200,80}})));
  Buildings.Controls.OBC.CDL.Interfaces.IntegerInput uSta
    "Current stage index"
    annotation (Placement(transformation(extent={{-280,10},{-240,50}}),
      iconTransformation(extent={{-240,0},{-200,40}})));
  Buildings.Controls.OBC.CDL.Interfaces.BooleanInput uConWatReq[nChi]
    "Condenser water requst status for each chiller"
    annotation (Placement(transformation(extent={{-280,-30},{-240,10}}),
      iconTransformation(extent={{-240,-40},{-200,0}})));
  Buildings.Controls.OBC.CDL.Interfaces.BooleanInput uWSE if haveWSE
    "Water side economizer status: true = ON, false = OFF"
    annotation (Placement(transformation(extent={{-280,-60},{-240,-20}}),
      iconTransformation(extent={{-240,-80},{-200,-40}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput uConWatPumSpe
    "Current condenser water pump speed"
    annotation (Placement(transformation(extent={{-280,-120},{-240,-80}}),
      iconTransformation(extent={{-240,-120},{-200,-80}})));
  Buildings.Controls.OBC.CDL.Interfaces.BooleanInput uChiHeaCon[nChi]
    "Chillers head pressure control status"
    annotation (Placement(transformation(extent={{-280,-150},{-240,-110}}),
      iconTransformation(extent={{-240,-160},{-200,-120}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput uChiWatIsoVal[nChi]
    "Chilled water isolation valve position"
    annotation (Placement(transformation(extent={{-280,-180},{-240,-140}}),
      iconTransformation(extent={{-240,-200},{-200,-160}})));
  Buildings.Controls.OBC.CDL.Interfaces.BooleanInput uChiWatReq[nChi]
    "Chilled water requst status for each chiller"
    annotation (Placement(transformation(extent={{-280,-240},{-240,-200}}),
      iconTransformation(extent={{-240,-240},{-200,-200}})));
  Buildings.Controls.OBC.CDL.Interfaces.BooleanOutput y
    "Indicate stage-up status: true=in stage-up process"
    annotation (Placement(transformation(extent={{240,200},{260,220}}),
      iconTransformation(extent={{200,180},{220,200}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput yChiDem[nChi]
    "Chiller demand setpoint"
    annotation (Placement(transformation(extent={{240,170},{260,190}}),
      iconTransformation(extent={{200,140},{220,160}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput yChiWatMinFloSet
    "Chilled water minimum flow setpoint" annotation (Placement(transformation(
          extent={{240,80},{260,100}}), iconTransformation(extent={{200,100},{
            220,120}})));
  Buildings.Controls.OBC.CDL.Interfaces.BooleanOutput yTowStaUp
    "Tower stage up status: true=stage up cooling tower"
    annotation (Placement(transformation(extent={{240,40},{260,60}}),
      iconTransformation(extent={{200,60},{220,80}})));
  Buildings.Controls.OBC.CDL.Interfaces.BooleanOutput yLeaConWatPum
    "Lead condenser water pump status"
    annotation (Placement(transformation(extent={{240,10},{260,30}}),
      iconTransformation(extent={{200,20},{220,40}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput yDesConWatPumSpe
    "Condenser water pump design speed at current stage"
    annotation (Placement(transformation(extent={{240,-20},{260,0}}),
      iconTransformation(extent={{200,-20},{220,0}})));
  Buildings.Controls.OBC.CDL.Interfaces.IntegerOutput yConWatPumNum
    "Number of operating condenser water pumps"
    annotation (Placement(transformation(extent={{240,-50},{260,-30}}),
      iconTransformation(extent={{200,-60},{220,-40}})));
  Buildings.Controls.OBC.CDL.Interfaces.BooleanOutput yChiHeaCon[nChi]
    "Chiller head pressure control enabling status"
    annotation (Placement(transformation(extent={{240,-100},{260,-80}}),
      iconTransformation(extent={{200,-100},{220,-80}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput yChiWatIsoVal[nChi]
    "Chiller chilled water isolation valve position"
    annotation (Placement(transformation(extent={{240,-160},{260,-140}}),
      iconTransformation(extent={{200,-150},{220,-130}})));
  Buildings.Controls.OBC.CDL.Interfaces.BooleanOutput yChi[nChi]
    "Chiller enabling status"
    annotation (Placement(transformation(extent={{240,-230},{260,-210}}),
      iconTransformation(extent={{200,-200},{220,-180}})));

  CDL.Logical.And and2 "Logical and"
    annotation (Placement(transformation(extent={{20,-70},{40,-50}})));
  CDL.Interfaces.BooleanInput uChiConIsoVal[nChi]
    "Chiller condenser water isolation valve status" annotation (Placement(
        transformation(extent={{-280,40},{-240,80}}), iconTransformation(extent
          ={{-264,30},{-224,70}})));
  CDL.Interfaces.RealInput uConWatPumSpeSet
    "Condenser water pump speed setpoint" annotation (Placement(transformation(
          extent={{-280,-90},{-240,-50}}), iconTransformation(extent={{-92,-86},
            {-52,-46}})));
protected
  Buildings.Controls.OBC.ASHRAE.PrimarySystem.ChillerPlant.Staging.Processes.Subsequences.NextChiller
    nexChi(
    final nChi=nChi,
    final havePonChi=havePonChi,
    final upOnOffSta=upOnOffSta,
    final dowOnOffSta=dowOnOffSta) "Identify next enabling chiller"
    annotation (Placement(transformation(extent={{-80,220},{-60,240}})));
  Buildings.Controls.OBC.ASHRAE.PrimarySystem.ChillerPlant.Staging.Processes.Subsequences.ReduceDemand
    chiDemRed(
    final nChi=nChi,
    final chiDemRedFac=chiDemRedFac,
    final holChiDemTim=holChiDemTim) "Limit chiller demand"
    annotation (Placement(transformation(extent={{-80,160},{-60,180}})));
  Buildings.Controls.OBC.ASHRAE.PrimarySystem.ChillerPlant.Staging.Processes.Subsequences.ResetMinBypass
    minBypSet(final aftByPasSetTim=aftByPasSetTim, final minFloDif=minFloDif)
    "Check if minium bypass has been reset"
    annotation (Placement(transformation(extent={{60,120},{80,140}})));
  Buildings.Controls.OBC.ASHRAE.PrimarySystem.ChillerPlant.Staging.Processes.Subsequences.EnableCWPump
    enaNexCWP
    "Identify correct stage number for enabling next condenser water pump"
    annotation (Placement(transformation(extent={{0,30},{20,50}})));
  Buildings.Controls.OBC.ASHRAE.PrimarySystem.ChillerPlant.Staging.Processes.Subsequences.HeadControl
    enaHeaCon(
    final nChi=nChi,
    final thrTimEnb=thrTimEnb,
    final waiTim=waiTim,
    final heaStaCha=heaStaCha)
    "Enabling head pressure control for next enabling chiller"
    annotation (Placement(transformation(extent={{60,-100},{80,-80}})));
  Buildings.Controls.OBC.ASHRAE.PrimarySystem.ChillerPlant.Staging.Processes.Subsequences.CHWIsoVal
    enaChiIsoVal(
    final nChi=nChi,
    final chaChiWatIsoTim=chaChiWatIsoTim,
    final iniValPos=iniValPos,
    final endValPos=endValPos)
    "Enable chilled water isolation valve for next enabling chiller"
    annotation (Placement(transformation(extent={{60,-160},{80,-140}})));
  Buildings.Controls.OBC.ASHRAE.PrimarySystem.ChillerPlant.Staging.Processes.Subsequences.UpEnd
    endUp(
    final nChi=nChi,
    final nSta=nSta,
    final proOnTim=proOnTim,
    final minFloSet=minFloSet,
    final byPasSetTim=byPasSetTim,
    final aftByPasSetTim=aftByPasSetTim,
    final minFloDif=minFloDif) "End stage-up process"
    annotation (Placement(transformation(extent={{60,-230},{80,-210}})));
  Buildings.Controls.OBC.ASHRAE.PrimarySystem.ChillerPlant.MinimumFlowBypass.Subsequences.FlowSetpoint
    minChiWatFlo(final byPasSetTim=byPasSetTim, final minFloSet=minFloSet)
    "Minimum chilled water flow setpoint"
    annotation (Placement(transformation(extent={{0,90},{20,110}})));
  Buildings.Controls.OBC.CDL.Logical.Sources.Constant con(final k=false)
    "False constant"
    annotation (Placement(transformation(extent={{-200,70},{-180,90}})));
  Buildings.Controls.OBC.ASHRAE.PrimarySystem.ChillerPlant.Pumps.CondenserWater.Controller
    conWatPumCon(
    final isHeadered=isHeadered,
    final haveWSE=haveWSE,
    final nSta=nSta,
    final chiNum=chiNum,
    final uLow=uLow,
    final uHigh=uHigh)
    "Enabling next condenser water pump or change pump speed"
    annotation (Placement(transformation(extent={{60,-20},{80,0}})));
  Buildings.Controls.OBC.CDL.Logical.MultiOr mulOr(final nu=nChi) "Multiple or"
    annotation (Placement(transformation(extent={{-80,0},{-60,20}})));
  Buildings.Controls.OBC.CDL.Logical.MultiOr mulOr1(final nu=nChi) "Multiple or"
    annotation (Placement(transformation(extent={{-80,-30},{-60,-10}})));
  Buildings.Controls.OBC.CDL.Logical.Switch swi[nChi] "Logical switch"
    annotation (Placement(transformation(extent={{200,-160},{220,-140}})));
  Buildings.Controls.OBC.CDL.Routing.BooleanReplicator booRep(final nout=nChi)
    "Replicate boolean input"
    annotation (Placement(transformation(extent={{120,-160},{140,-140}})));
  Buildings.Controls.OBC.CDL.Logical.LogicalSwitch logSwi[nChi] "Logical switch"
    annotation (Placement(transformation(extent={{200,-100},{220,-80}})));
  Buildings.Controls.OBC.CDL.Logical.Switch swi1 "Logical switch"
    annotation (Placement(transformation(extent={{200,80},{220,100}})));
  Buildings.Controls.OBC.CDL.Logical.Edge edg
    "Rising edge, output true at the moment when input turns from false to true"
    annotation (Placement(transformation(extent={{-200,200},{-180,220}})));
  Buildings.Controls.OBC.CDL.Logical.Latch lat
    "Logical latch, maintain ON signal until condition changes"
    annotation (Placement(transformation(extent={{-140,200},{-120,220}})));

  CDL.Continuous.Sources.Constant                        con1(final k=0)
               "Constant zero"
    annotation (Placement(transformation(extent={{-200,130},{-180,150}})));
equation
  connect(chiDemRed.yChiDemRed, minBypSet.uUpsDevSta) annotation (Line(points={{-58,166},
          {-32,166},{-32,138},{58,138}},  color={255,0,255}));
  connect(uStaUp, edg.u)
    annotation (Line(points={{-260,210},{-202,210}}, color={255,0,255}));
  connect(edg.y, lat.u)
    annotation (Line(points={{-178,210},{-142,210}}, color={255,0,255}));
  connect(lat.y, nexChi.uStaUp) annotation (Line(points={{-118,210},{-100,210},
          {-100,230},{-82,230}},color={255,0,255}));
  connect(lat.y,chiDemRed.uDemLim)  annotation (Line(points={{-118,210},{-100,
          210},{-100,179},{-82,179}}, color={255,0,255}));
  connect(chiDemRed.uChiLoa, uChiLoa)
    annotation (Line(points={{-82,175},{-180,175},{-180,170},{-260,170}},
                                                    color={0,0,127}));
  connect(chiDemRed.uChi, uChi) annotation (Line(points={{-82,161},{-220,161},{
          -220,130},{-260,130}},
                            color={255,0,255}));
  connect(lat.y, minBypSet.uStaCha) annotation (Line(points={{-118,210},{-100,
          210},{-100,134},{58,134}},
                               color={255,0,255}));
  connect(minBypSet.VChiWat_flow, VChiWat_flow) annotation (Line(points={{58,
          126},{-156,126},{-156,100},{-260,100}}, color={0,0,127}));
  connect(lat.y, minChiWatFlo.uStaUp) annotation (Line(points={{-118,210},{-100,
          210},{-100,109},{-2,109}}, color={255,0,255}));
  connect(chiDemRed.yChiDemRed, minChiWatFlo.uUpsDevSta) annotation (Line(
        points={{-58,166},{-32,166},{-32,107},{-2,107}}, color={255,0,255}));
  connect(con.y, minChiWatFlo.uStaDow) annotation (Line(points={{-178,80},{-96,
          80},{-96,91},{-2,91}}, color={255,0,255}));
  connect(minBypSet.yMinBypRes, enaNexCWP.uUpsDevSta) annotation (Line(points={{82,130},
          {120,130},{120,70},{-32,70},{-32,48},{-2,48}},       color={255,0,255}));
  connect(lat.y, enaNexCWP.uStaUp) annotation (Line(points={{-118,210},{-100,
          210},{-100,42},{-2,42}},
                                 color={255,0,255}));
  connect(uSta, enaNexCWP.uSta) annotation (Line(points={{-260,30},{-104,30},{
          -104,32},{-2,32}},
                        color={255,127,0}));
  connect(conWatPumCon.uWSE, uWSE) annotation (Line(points={{58,-14},{-4,-14},{
          -4,-40},{-260,-40}},
                            color={255,0,255}));
  connect(conWatPumCon.uConWatPumSpe, uConWatPumSpe) annotation (Line(points={{58,-19},
          {4,-19},{4,-100},{-260,-100}},      color={0,0,127}));
  connect(enaNexCWP.ySta, conWatPumCon.uChiSta) annotation (Line(points={{22,40},
          {40,40},{40,-11},{58,-11}}, color={255,127,0}));
  connect(lat.y, enaHeaCon.uStaCha) annotation (Line(points={{-118,210},{-100,
          210},{-100,-86},{58,-86}},
                               color={255,0,255}));
  connect(nexChi.yNexEnaChi, enaHeaCon.nexChaChi) annotation (Line(points={{-58,
          239},{-36,239},{-36,-94},{58,-94}}, color={255,127,0}));
  connect(enaHeaCon.uChiHeaCon, uChiHeaCon) annotation (Line(points={{58,-98},{
          -48,-98},{-48,-130},{-260,-130}},
                                        color={255,0,255}));
  connect(nexChi.yNexEnaChi, enaChiIsoVal.nexChaChi) annotation (Line(points={{-58,
          239},{-36,239},{-36,-142},{58,-142}}, color={255,127,0}));
  connect(enaChiIsoVal.uChiWatIsoVal, uChiWatIsoVal) annotation (Line(points={{58,-145},
          {-96,-145},{-96,-160},{-260,-160}},       color={0,0,127}));
  connect(enaHeaCon.yEnaHeaCon,enaChiIsoVal.uUpsDevSta)  annotation (Line(
        points={{82,-84},{96,-84},{96,-120},{40,-120},{40,-155},{58,-155}},
        color={255,0,255}));
  connect(lat.y, enaChiIsoVal.uStaCha) annotation (Line(points={{-118,210},{
          -100,210},{-100,-158},{58,-158}},
                                       color={255,0,255}));
  connect(nexChi.yNexEnaChi, endUp.nexEnaChi) annotation (Line(points={{-58,239},
          {-36,239},{-36,-210},{58,-210}}, color={255,127,0}));
  connect(lat.y, endUp.uStaUp) annotation (Line(points={{-118,210},{-100,210},{-100,
          -212},{58,-212}}, color={255,0,255}));
  connect(enaChiIsoVal.yEnaChiWatIsoVal, endUp.uEnaChiWatIsoVal) annotation (
      Line(points={{82,-144},{100,-144},{100,-180},{40,-180},{40,-214},{58,-214}},
        color={255,0,255}));
  connect(uChi, endUp.uChi) annotation (Line(points={{-260,130},{-220,130},{-220,
          -216},{58,-216}}, color={255,0,255}));
  connect(endUp.uChiWatReq, uChiWatReq) annotation (Line(points={{58,-222},{-44,
          -222},{-44,-220},{-260,-220}},
                                  color={255,0,255}));
  connect(endUp.uChiWatIsoVal, uChiWatIsoVal) annotation (Line(points={{58,-224},
          {-96,-224},{-96,-160},{-260,-160}}, color={0,0,127}));
  connect(uConWatReq, endUp.uConWatReq) annotation (Line(points={{-260,-10},{
          -164,-10},{-164,-226},{58,-226}},
                                       color={255,0,255}));
  connect(uChiHeaCon, endUp.uChiHeaCon) annotation (Line(points={{-260,-130},{
          -48,-130},{-48,-228},{58,-228}},
                                       color={255,0,255}));
  connect(VChiWat_flow, endUp.VChiWat_flow) annotation (Line(points={{-260,100},
          {-156,100},{-156,-230},{58,-230}}, color={0,0,127}));

  connect(uConWatReq, mulOr1.u) annotation (Line(points={{-260,-10},{-164,-10},
          {-164,-20},{-82,-20}},            color={255,0,255}));
  connect(uChi, mulOr.u) annotation (Line(points={{-260,130},{-220,130},{-220,
          10},{-82,10}},                    color={255,0,255}));

  connect(nexChi.uChiPri, uChiPri) annotation (Line(points={{-82,238},{-220,238},
          {-220,250},{-260,250}}, color={255,127,0}));
  connect(uChi, nexChi.uChiEna) annotation (Line(points={{-260,130},{-220,130},{
          -220,234},{-82,234}}, color={255,0,255}));
  connect(chiDemRed.yChiDem, yChiDem) annotation (Line(points={{-58,174},{100,
          174},{100,180},{250,180}},
                                color={0,0,127}));
  connect(conWatPumCon.yLeaPum, yLeaConWatPum) annotation (Line(points={{82,-1},
          {120,-1},{120,20},{250,20}},  color={255,0,255}));
  connect(endUp.yChi, yChi) annotation (Line(points={{82,-211},{220,-211},{220,-220},
          {250,-220}}, color={255,0,255}));
  connect(enaChiIsoVal.yEnaChiWatIsoVal, booRep.u) annotation (Line(points={{82,-144},
          {100,-144},{100,-150},{118,-150}},       color={255,0,255}));
  connect(booRep.y, swi.u2)
    annotation (Line(points={{142,-150},{198,-150}}, color={255,0,255}));
  connect(endUp.yChiWatIsoVal, swi.u1) annotation (Line(points={{82,-215},{184,-215},
          {184,-142},{198,-142}}, color={0,0,127}));
  connect(swi.y, yChiWatIsoVal)
    annotation (Line(points={{222,-150},{250,-150}}, color={0,0,127}));
  connect(booRep.y, logSwi.u2) annotation (Line(points={{142,-150},{176,-150},{176,
          -90},{198,-90}}, color={255,0,255}));
  connect(endUp.yChiHeaCon, logSwi.u1) annotation (Line(points={{82,-220},{172,-220},
          {172,-82},{198,-82}}, color={255,0,255}));
  connect(enaHeaCon.yChiHeaCon, logSwi.u3) annotation (Line(points={{82,-96},{
          140,-96},{140,-98},{198,-98}},
                                       color={255,0,255}));
  connect(logSwi.y, yChiHeaCon)
    annotation (Line(points={{222,-90},{250,-90}}, color={255,0,255}));
  connect(enaChiIsoVal.yEnaChiWatIsoVal, swi1.u2) annotation (Line(points={{82,-144},
          {100,-144},{100,90},{198,90}}, color={255,0,255}));
  connect(endUp.yChiWatMinSet, swi1.u1) annotation (Line(points={{82,-225},{180,
          -225},{180,98},{198,98}}, color={0,0,127}));
  connect(swi1.y, yChiWatMinFloSet)
    annotation (Line(points={{222,90},{250,90}}, color={0,0,127}));
  connect(endUp.yEndSta, lat.u0) annotation (Line(points={{81,-229},{100,-229},{
          100,-240},{-160,-240},{-160,204},{-141,204}}, color={255,0,255}));
  connect(enaChiIsoVal.yChiWatIsoVal, swi.u3) annotation (Line(points={{82,-156},
          {96,-156},{96,-166},{188,-166},{188,-158},{198,-158}}, color={0,0,127}));
  connect(uSta, nexChi.uSta) annotation (Line(points={{-260,30},{-104,30},{-104,
          226},{-82,226}}, color={255,127,0}));
  connect(con.y, nexChi.uStaDow) annotation (Line(points={{-178,80},{-96,80},{
          -96,222},{-82,222}},
                           color={255,0,255}));
  connect(nexChi.yDisSmaChi, endUp.nexDisChi) annotation (Line(points={{-58,234},
          {-40,234},{-40,-220},{58,-220}}, color={255,127,0}));

  connect(nexChi.yOnOff, minChiWatFlo.uOnOff) annotation (Line(points={{-58,230},
          {-44,230},{-44,93},{-2,93}}, color={255,0,255}));
  connect(nexChi.yOnOff, endUp.uOnOff) annotation (Line(points={{-58,230},{-44,230},
          {-44,-218},{58,-218}}, color={255,0,255}));
  connect(con.y, enaNexCWP.uStaDow) annotation (Line(points={{-178,80},{-96,80},
          {-96,38},{-2,38}}, color={255,0,255}));
  connect(lat.y, y)
    annotation (Line(points={{-118,210},{250,210}}, color={255,0,255}));
  connect(minBypSet.yMinBypRes, yTowStaUp) annotation (Line(points={{82,130},{
          120,130},{120,50},{250,50}},
                                  color={255,0,255}));
  connect(minBypSet.yMinBypRes, and2.u2) annotation (Line(points={{82,130},{120,
          130},{120,70},{-32,70},{-32,-68},{18,-68}},color={255,0,255}));
  connect(conWatPumCon.yPumSpeChe, and2.u1) annotation (Line(points={{82,-19},{
          90,-19},{90,-40},{8,-40},{8,-60},{18,-60}}, color={255,0,255}));
  connect(and2.y, enaHeaCon.uUpsDevSta) annotation (Line(points={{42,-60},{50,
          -60},{50,-82},{58,-82}}, color={255,0,255}));
  connect(con.y, chiDemRed.uStaDow) annotation (Line(points={{-178,80},{-96,80},
          {-96,168},{-82,168}}, color={255,0,255}));
  connect(con1.y, chiDemRed.minOPLR) annotation (Line(points={{-178,140},{-140,140},
          {-140,171},{-82,171}}, color={0,0,127}));
  connect(uChi, minChiWatFlo.uChi) annotation (Line(points={{-260,130},{-220,
          130},{-220,104},{-2,104}}, color={255,0,255}));
  connect(nexChi.yNexEnaChi, minChiWatFlo.nexEnaChi) annotation (Line(points={{
          -58,239},{-36,239},{-36,101},{-2,101}}, color={255,127,0}));
  connect(nexChi.yDisSmaChi, minChiWatFlo.nexDisChi) annotation (Line(points={{
          -58,234},{-40,234},{-40,99},{-2,99}}, color={255,127,0}));
  connect(con.y, minChiWatFlo.uSubCha) annotation (Line(points={{-178,80},{-96,
          80},{-96,96},{-2,96}}, color={255,0,255}));
  connect(nexChi.yOnOff, chiDemRed.uOnOff) annotation (Line(points={{-58,230},{
          -44,230},{-44,200},{-92,200},{-92,165},{-82,165}}, color={255,0,255}));
  connect(minChiWatFlo.yChiWatMinFloSet, minBypSet.VMinChiWat_setpoint)
    annotation (Line(points={{22,100},{40,100},{40,122},{58,122}}, color={0,0,
          127}));
  connect(minChiWatFlo.yChiWatMinFloSet, swi1.u3) annotation (Line(points={{22,
          100},{40,100},{40,82},{198,82}}, color={0,0,127}));
  connect(conWatPumCon.yDesConWatPumSpe, yDesConWatPumSpe) annotation (Line(
        points={{82,-7},{120,-7},{120,-10},{250,-10}}, color={0,0,127}));
  connect(conWatPumCon.uChiConIsoVal, uChiConIsoVal) annotation (Line(points={{
          58,0},{52,0},{52,60},{-260,60}}, color={255,0,255}));
  connect(mulOr.y, conWatPumCon.uLeaChiSta) annotation (Line(points={{-58,10},{
          48,10},{48,-5},{58,-5}}, color={255,0,255}));
  connect(mulOr.y, conWatPumCon.uLeaChiEna) annotation (Line(points={{-58,10},{
          48,10},{48,-3},{58,-3}}, color={255,0,255}));
  connect(mulOr1.y, conWatPumCon.uLeaConWatReq) annotation (Line(points={{-58,
          -20},{-8,-20},{-8,-8},{58,-8}}, color={255,0,255}));
  connect(conWatPumCon.uConWatPumSpeSet, uConWatPumSpeSet) annotation (Line(
        points={{58,-17},{0,-17},{0,-70},{-260,-70}}, color={0,0,127}));
  connect(conWatPumCon.yConWatPumNum, yConWatPumNum) annotation (Line(points={{
          82,-13},{120,-13},{120,-40},{250,-40}}, color={255,127,0}));
annotation (
  defaultComponentName="upProCon",
  Diagram(coordinateSystem(preserveAspectRatio=false,
          extent={{-240,-260},{240,260}})),
    Icon(coordinateSystem(extent={{-200,-200},{200,200}}), graphics={
        Rectangle(
        extent={{-200,-200},{200,200}},
        lineColor={0,0,127},
        fillColor={255,255,255},
        fillPattern=FillPattern.Solid),
        Text(
          extent={{-240,270},{200,210}},
          lineColor={0,0,255},
          textString="%name")}));
end Up;