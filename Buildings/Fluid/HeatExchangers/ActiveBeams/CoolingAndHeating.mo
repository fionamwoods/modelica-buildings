within Buildings.Fluid.HeatExchangers.ActiveBeams;
model CoolingAndHeating "Active beam unit for heating and cooling"
  extends Buildings.Fluid.HeatExchangers.ActiveBeams.Cooling(sum(nin=2));

  replaceable parameter Data.Generic perHea "Performance data for heating"
    annotation (
      Dialog(group="Nominal condition"),
      choicesAllMatching=true,
      Placement(transformation(extent={{40,-92},{60,-72}})));

  // Initialization
  parameter MediumWat.AbsolutePressure pWatHea_start = pWatCoo_start
    "Start value of pressure"
    annotation(Dialog(tab = "Initialization", group = "Heating"));

  parameter MediumWat.Temperature TWatHea_start = TWatCoo_start
    "Start value of temperature"
    annotation(Dialog(tab = "Initialization", group = "Heating"));

  Modelica.Fluid.Interfaces.FluidPort_a watHea_a(
    redeclare final package Medium = MediumWat,
    m_flow(min=if allowFlowReversalWat then -Modelica.Constants.inf else 0),
    h_outflow(start=MediumWat.h_default))
    "Fluid connector a (positive design flow direction is from watHea_a to watHea_b)"
    annotation (Placement(transformation(extent={{-150,-10},{-130,10}})));
  Modelica.Fluid.Interfaces.FluidPort_b watHea_b(
    redeclare final package Medium = MediumWat,
    m_flow(max=if allowFlowReversalWat then +Modelica.Constants.inf else 0),
    h_outflow(start=MediumWat.h_default))
    "Fluid connector b (positive design flow direction is from watHea_a to watHea_b)"
    annotation (Placement(transformation(extent={{150,-10},{130,10}})));

  MediumWat.ThermodynamicState staHea_a=
      MediumWat.setState_phX(watHea_a.p,
                          noEvent(actualStream(watHea_a.h_outflow)),
                          noEvent(actualStream(watHea_a.Xi_outflow))) if
         show_T "Medium properties in port watHea_a";

  MediumWat.ThermodynamicState staHea_b=
      MediumWat.setState_phX(watHea_b.p,
                          noEvent(actualStream(watHea_b.h_outflow)),
                          noEvent(actualStream(watHea_b.Xi_outflow))) if
          show_T "Medium properties in port watHea_b";

  Modelica.SIunits.PressureDifference dpWatHea(displayUnit="Pa") = watHea_a.p - watHea_b.p
    "Pressure difference between watHea_a and watHea_b";

protected
  BaseClasses.Convector conHea(
    redeclare final package Medium = MediumWat,
    final per=perHea,
    final allowFlowReversal=allowFlowReversalWat,
    final m_flow_small=mWat_flow_small,
    final show_T=false,
    final homotopyInitialization=homotopyInitialization,
    final from_dp=from_dpWat,
    final linearizeFlowResistance=linearizeFlowResistanceWat,
    final deltaM=deltaMWat,
    final tau=tau,
    final energyDynamics=energyDynamics,
    final massDynamics=massDynamics,
    final p_start=pWatHea_start,
    final T_start=TWatHea_start,
    final nBeams=nBeams) "Heating beam"
    annotation (Placement(transformation(extent={{-10,-10},{10,10}})));

  Sensors.MassFlowRate senFlo2(
    redeclare final package Medium = MediumWat)
    annotation (Placement(transformation(extent={{-120,-10},{-100,10}})));
  Modelica.Blocks.Math.Gain gaiWatHeaFlo(final k=1/nBeams)
    "Gain to scale water mass flow rate to a single beam" annotation (Placement(
        transformation(
        extent={{-10,-10},{10,10}},
        rotation=0,
        origin={-70,30})));

initial equation
  assert(perHea.primaryAir.r_V[1]<=0.000001 and perHea.primaryAir.f[1]<=0.00001,
    "Performance curve perHea.primaryAir must pass through (0,0).");
  assert(perHea.water.r_V[1]<=0.000001      and perHea.water.f[1]<=0.00001,
    "Performance curve perHea.water must pass through (0,0).");
  assert(perHea.dT.r_dT[1]<=0.000001        and perHea.dT.f[1]<=0.00001,
    "Performance curve perHea.dT must pass through (0,0).");

equation

  connect(conHea.port_b, watHea_b)
    annotation (Line(points={{10,0},{140,0}}, color={0,127,255}));
  connect(conHea.Q_flow, sum.u[2])
    annotation (Line(points={{11,7},{20,7},{20,30},{38,30}}, color={0,0,127}));
  connect(watHea_a, senFlo2.port_a)
    annotation (Line(points={{-140,0},{-120,0}}, color={0,127,255}));
  connect(senFlo2.port_b, conHea.port_a)
    annotation (Line(points={{-100,0},{-100,0},{-10,0}}, color={0,127,255}));
  connect(gaiWatHeaFlo.y, conHea.mWat_flow) annotation (Line(points={{-59,30},{-28,
          30},{-28,9},{-12,9}}, color={0,0,127}));
  connect(conHea.mAir_flow, gaiAirFlo.y)
    annotation (Line(points={{-12,4},{-90,4},{-90,-19}}, color={0,0,127}));
  connect(senFlo2.m_flow, gaiWatHeaFlo.u)
    annotation (Line(points={{-110,11},{-110,30},{-82,30}}, color={0,0,127}));
  connect(conHea.TRoo, senTemRooAir.T) annotation (Line(points={{-12,-6},{-26,-6},
          {-50,-6},{-50,-40},{-40,-40}}, color={0,0,127}));
  annotation (Diagram(coordinateSystem(preserveAspectRatio=false, extent={{-140,
            -120},{140,120}})), defaultComponentName="beaCooHea",Icon(
        coordinateSystem(extent={{-140,-120},{140,120}}),             graphics={
        Rectangle(
          extent={{-120,6},{-138,-6}},
          lineColor={0,0,0},
          fillColor={0,0,0},
          fillPattern=FillPattern.Solid),
        Rectangle(
          extent={{138,6},{120,-6}},
          lineColor={0,0,0},
          fillColor={0,0,0},
          fillPattern=FillPattern.Solid),
        Rectangle(
          extent={{-60,-34},{0,-80}},
          fillColor={255,0,0},
          fillPattern=FillPattern.VerticalCylinder,
          pattern=LinePattern.None,
          lineColor={0,0,0}),
        Rectangle(
          extent={{0,-34},{64,-80}},
          fillColor={0,128,255},
          fillPattern=FillPattern.VerticalCylinder,
          pattern=LinePattern.None,
          lineColor={0,0,0}),
        Line(points={{-112,0},{-66,0},{-82,10}}, color={0,0,0}),
        Line(points={{-66,0},{-82,-8}}, color={0,0,0})}),
          Documentation(info="<html>
<p>
This model is similar to
<a href=\"modelica://Buildings.Fluid.HeatExchangers.ActiveBeams.Cooling\">
Buildings.Fluid.HeatExchangers.ActiveBeams.Cooling</a>.
An additional fluid stream is added to allow for
the heating mode.
</p>
<p>
In this model, the temperature difference <i><code>&#916;</code>T</i> used for the calculation of the modification factor <i>f<sub><code>&#916;</code>T</sub>(&middot;)</i> is
</p>
<p align=\"center\" style=\"font-style:italic;\">
&#916;T = T<sub>HW</sub>-T<sub>Z</sub>,
</p>
<p> 
where <i>T<sub>HW</sub></i> is the hot water temperature entering the convector in heating mode
and <i>T<sub>Z</sub></i> is the zone air temperature.
</p>
</html>", revisions="<html>
<ul>
<li>
June 14, 2016, by Michael Wetter:<br/>
Revised implementation.
</li>
<li>
May 20, 2016, by Alessandro Maccarini:<br/>
First implementation.
</li>
</ul>
</html>"));
end CoolingAndHeating;
