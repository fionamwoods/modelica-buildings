within Buildings.Applications.DHC.Loads.Examples;
model CouplingRC
  "Example illustrating the coupling of a RC building model to a fluid loop"
  extends Modelica.Icons.Example;
  Buildings.BoundaryConditions.WeatherData.ReaderTMY3 weaDat(
    calTSky=Buildings.BoundaryConditions.Types.SkyTemperatureCalculation.HorizontalRadiation,
    computeWetBulbTemperature=false,
    filNam=Modelica.Utilities.Files.loadResource(
        "modelica://Buildings/Resources/weatherdata/USA_CA_San.Francisco.Intl.AP.724940_TMY3.mos"))
    "Weather data reader"
    annotation (Placement(transformation(extent={{60,100},{40,120}})));
  package Medium1 = Buildings.Media.Water
    "Source side medium";
  BaseClasses.RCBuilding bui
    annotation (Placement(transformation(extent={{20,40},{40,60}})));
  Buildings.Fluid.Sources.Boundary_pT sinHea(
    redeclare package Medium = Medium1,
    nPorts=1) "Sink for heating water"
    annotation (Placement(transformation(
        extent={{10,-10},{-10,10}},
        rotation=0,
        origin={110,90})));
  Buildings.Fluid.Sources.Boundary_pT sinCoo(
    redeclare package Medium = Medium1,
    nPorts=1) "Sink for chilled water"
    annotation (Placement(transformation(
        extent={{10,-10},{-10,10}},
        rotation=0,
        origin={110,10})));
  Fluid.Sources.MassFlowSource_T           supHea(
    use_m_flow_in=true,
    redeclare package Medium = Medium1,
    use_T_in=true,
    nPorts=1) "Supply for heating water"          annotation (Placement(
        transformation(
        extent={{-10,-10},{10,10}},
        rotation=0,
        origin={-34,80})));
  Modelica.Blocks.Sources.RealExpression THeaInlVal(y=bui.terUni.T_a1Hea_nominal)
    annotation (Placement(transformation(extent={{-104,64},{-84,84}})));
  Modelica.Blocks.Sources.RealExpression mHea_flow(y=bui.disFloHea.mReq_flow)
    annotation (Placement(transformation(extent={{-104,84},{-84,104}})));
  Fluid.Sources.MassFlowSource_T           supCoo(
    use_m_flow_in=true,
    redeclare package Medium = Medium1,
    use_T_in=true,
    nPorts=1) "Supply for chilled water"
    annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=0,
        origin={-34,0})));
  Modelica.Blocks.Sources.RealExpression TCooInlVal(y=bui.terUni.T_a1Coo_nominal)
    annotation (Placement(transformation(extent={{-104,-16},{-84,4}})));
  Modelica.Blocks.Sources.RealExpression mCoo_flow(y=bui.disFloCoo.mReq_flow)
    annotation (Placement(transformation(extent={{-104,4},{-84,24}})));
equation
  connect(weaDat.weaBus, bui.weaBus)
  annotation (Line(
      points={{40,110},{30,110},{30,60},{30.1,60}},
      color={255,204,51},
      thickness=0.5));
  connect(bui.ports_b1[1], sinHea.ports[1])
    annotation (Line(points={{40,44},{74,44},{74,90},{100,90}}, color={0,127,255}));
  connect(bui.ports_b1[2], sinCoo.ports[1])
    annotation (Line(points={{40,44},{74,44},{74,10},{100,10}}, color={0,127,255}));
  connect(THeaInlVal.y,supHea. T_in) annotation (Line(points={{-83,74},{-64,74},
          {-64,84},{-46,84}},                                                                       color={0,0,127}));
  connect(mHea_flow.y, supHea.m_flow_in) annotation (Line(points={{-83,94},{-64,
          94},{-64,88},{-46,88}}, color={0,0,127}));
  connect(TCooInlVal.y,supCoo. T_in) annotation (Line(points={{-83,-6},{-64,-6},
          {-64,4},{-46,4}},  color={0,0,127}));
  connect(mCoo_flow.y, supCoo.m_flow_in) annotation (Line(points={{-83,14},{-64,
          14},{-64,8},{-46,8}}, color={0,0,127}));
  connect(supHea.ports[1], bui.ports_a1[1])
    annotation (Line(points={{-24,80},{0,80},{0,44},{20,44}}, color={0,127,255}));
  connect(supCoo.ports[1], bui.ports_a1[2])
    annotation (Line(points={{-24,0},{0,0},{0,44},{20,44}},   color={0,127,255}));
  annotation (
  experiment(
      StopTime=604800,
      Tolerance=1e-06,
      __Dymola_Algorithm="Cvode"),
  Documentation(info="<html>
  <p>
  This example illustrates the use of
  <a href=\"modelica://Buildings.DistrictEnergySystem.Loads.BaseClasses.HeatingOrCooling\">
  Buildings.DistrictEnergySystem.Loads.BaseClasses.HeatingOrCooling</a>
  to transfer heat from a fluid stream to a simplified building model consisting in two heating loads and one cooling
  load as described in
  <a href=\"modelica://Buildings.DistrictEnergySystem.Loads.Examples.BaseClasses.RCBuilding\">
  Buildings.DistrictEnergySystem.Loads.Examples.BaseClasses.RCBuilding</a>.
  </p>
  </html>"),
  Diagram(
  coordinateSystem(preserveAspectRatio=false, extent={{-120,-20},{140,120}})),
  __Dymola_Commands(file="Resources/Scripts/Dymola/Applications/DHC/Loads/Examples/CouplingRC.mos"
        "Simulate and plot"));
end CouplingRC;