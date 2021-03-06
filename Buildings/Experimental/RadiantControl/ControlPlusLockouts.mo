within Buildings.Experimental.RadiantControl;
block ControlPlusLockouts "Full radiant control"
   parameter Real TAirHiSet(min=0,
    final unit="K",
    final displayUnit="degC",
    final quantity="Temperature")=297.6
    "Air temperature high limit above which heating is locked out";
    parameter Real TAirLoSet(min=0,
    final unit="K",
    final displayUnit="degC",
    final quantity="Temperature")=293.15
    "Air temperature low limit below which heating is locked out";
    parameter Real TWaLoSet(min=0,
    final unit="K",
    final displayUnit="degC",
    final quantity="Temperature")=285.9
    "Lower limit for chilled water return temperature, below which cooling is locked out";
    parameter Real TiCHW(min=0,
    final unit="s",
    final displayUnit="s",
    final quantity="Time")=1800 "Time for which cooling is locked if CHW return is too cold";

   parameter Real TiHea(min=0,
    final unit="s",
    final displayUnit="s",
    final quantity="Time") = 3600 "Time for which heating is locked out after cooling concludes";
    parameter Real TiCoo(min=0,
    final unit="s",
    final displayUnit="s",
    final quantity="Time") = 3600 "Time for which cooling is locked out after heating concludes";
  parameter Real TDeaRel(min=0,
    final unit="K",
    final displayUnit="degC",
    final quantity="TemperatureDifference")=2.22 "Difference from slab temp setpoint required to trigger alarm during occupied hours";
parameter Real TDeaNor(min=0,
    final unit="K",
    final displayUnit="degC",
    final quantity="TemperatureDifference")=0.28
                                           "Difference from slab temp setpoint required to trigger alarm during unoccpied hours";
  parameter Real k(min=0,max=24)=18 "Last occupied hour";
 parameter Boolean off_within_deadband=true "If flow should turn off when slab setpoint is within deadband, set to true. Otherwise, set to false";
  Controls.OBC.CDL.Logical.And and2 "Final Heating Signal"
    annotation (Placement(transformation(extent={{20,40},{40,60}})));
  Controls.OBC.CDL.Logical.And and1 "Final cooling signal"
    annotation (Placement(transformation(extent={{20,-20},{40,0}})));
  Controls.OBC.CDL.Interfaces.RealInput TRooAir "Room air temperature"
    annotation (Placement(transformation(extent={{-140,-60},{-100,-20}})));
  Controls.OBC.CDL.Interfaces.RealInput TSla "Measured slab temperature"
    annotation (Placement(transformation(extent={{-140,60},{-100,100}})));
  Controls.OBC.CDL.Interfaces.RealInput TWaRet "Water return temperature"
    annotation (Placement(transformation(extent={{-140,-100},{-100,-60}})));
  SlabTemperatureSignal.Error err "Slab temperature error"
    annotation (Placement(transformation(extent={{-58,40},{-38,60}})));
  Controls.OBC.CDL.Interfaces.RealInput TSlaSet "Slab temperature setpoint"
    annotation (Placement(transformation(extent={{-140,20},{-100,60}})));
  Controls.OBC.CDL.Interfaces.BooleanInput nitFluSig
    "Night flush signal- true if night flush on; false if not"
    annotation (Placement(transformation(extent={{-140,-20},{-100,20}})));
  Controls.OBC.CDL.Interfaces.BooleanOutput htgSig
    "True if heating is called for; false if not"
    annotation (Placement(transformation(extent={{100,24},{140,64}})));
  Controls.OBC.CDL.Interfaces.BooleanOutput clgSig
    "True if cooling is called for; false if not"
    annotation (Placement(transformation(extent={{100,-50},{140,-10}})));
  Lockouts.AllLockouts allLoc(
    TAirHiSet=TAirHiSet,
    TAirLoSet=TAirLoSet,
    TWaLoSet=TWaLoSet,
    TiCHW=TiCHW,
    TiHea=TiHea,
    TiCoo=TiCoo) "All lockouts, combined"
    annotation (Placement(transformation(extent={{-20,0},{0,20}})));
  SlabTemperatureSignal.DeadbandControl deaCon(
    TDeaRel=TDeaRel,
    TDeaNor=TDeaNor,
    k=k) "Slab temperature deadband control"
    annotation (Placement(transformation(extent={{-24,38},{6,68}})));
  Controls.OBC.CDL.Logical.Pre pre "Breaks recursive loop"
    annotation (Placement(transformation(extent={{60,-40},{80,-20}})));
  Controls.OBC.CDL.Logical.Pre pre1 "Breaks recursive loop"
    annotation (Placement(transformation(extent={{60,60},{80,80}})));
equation
  connect(err.TSlaSet, TSlaSet) annotation (Line(points={{-60,47},{-60,48},{-96,
          48},{-96,40},{-120,40}}, color={0,0,127}));
  connect(err.TSla, TSla)
    annotation (Line(points={{-60,51},{-60,80},{-120,80}}, color={0,0,127}));
  connect(and1.y, clgSig) annotation (Line(points={{42,-10},{94,-10},{94,-30},{120,
          -30}}, color={255,0,255}));
  connect(and2.y, htgSig) annotation (Line(points={{42,50},{94,50},{94,44},{120,
          44}}, color={255,0,255}));
  connect(nitFluSig, allLoc.nitFluSig) annotation (Line(points={{-120,0},{-86,0},
          {-86,19},{-22,19}}, color={255,0,255}));
  connect(TRooAir, allLoc.TRooAir) annotation (Line(points={{-120,-40},{-78,-40},
          {-78,7},{-22,7}}, color={0,0,127}));
  connect(TWaRet, allLoc.TChwRet) annotation (Line(points={{-120,-80},{-40,-80},
          {-40,3},{-22,3}}, color={0,0,127}));
  connect(allLoc.htgSigL, and2.u2) annotation (Line(points={{2,13},{16,13},{16,
          42},{18,42}}, color={255,0,255}));
  connect(allLoc.clgSigL, and1.u2) annotation (Line(points={{2,5},{6,5},{6,-18},
          {18,-18}}, color={255,0,255}));
  connect(err.slaTemErr, deaCon.slaTemErr) annotation (Line(points={{-36,51},{-32,
          51},{-32,39.2},{-26.6,39.2}}, color={0,0,127}));
  connect(deaCon.clgCal, and1.u1) annotation (Line(points={{8,44},{12,44},{12,-10},
          {18,-10}}, color={255,0,255}));
  connect(deaCon.htgCal, and2.u1) annotation (Line(points={{8,54},{14,54},{14,
          50},{18,50}}, color={255,0,255}));
  connect(and1.y, pre.u) annotation (Line(points={{42,-10},{50,-10},{50,-30},{
          58,-30}}, color={255,0,255}));
  connect(pre.y, allLoc.clgSig) annotation (Line(points={{82,-30},{86,-30},{86,
          -60},{-60,-60},{-60,11},{-22,11}}, color={255,0,255}));
  connect(and2.y, pre1.u) annotation (Line(points={{42,50},{50,50},{50,70},{58,
          70}}, color={255,0,255}));
  connect(pre1.y, allLoc.htgSig) annotation (Line(points={{82,70},{84,70},{84,
          94},{-74,94},{-74,15},{-22,15}}, color={255,0,255}));
  annotation (defaultComponentName = "conPluLoc",Documentation(info="<html>
<p>
This encompasses full radiant control based on water return temperature, room air temperature, night flush signal, slab temperature, and slab setpoint. <p>

<p> Each day, a slab temperature setpoint for a perimeter zone should be determined based on a lookup table that references the forecast high outdoor air temperature.
See Buildings.Experimental.RadiantControl.SlabTempSignal.SlabSetPerim.

Core zone setpoints are set to a constant value throughout the year (typically 70F). <p>

 <p>

The user specifies a deadband for occupied hours (TDeaNor,typically 0.5F) and one for unoccupied hours (TDeaRel, typically 4F).
Each day, from midnight until the last occupied hour, a call for heating or cooling is produced if the setpoint is not met within the occupied deadband.
After the last occupied hour (k, typically 18 = 6PM), calls for heating or cooling are produced if the setpoint is not met within the unoccupied deadband.  <p>


<p> If there is a call for heating (ie, the slab temperature is below its setpoint minus a user-specified deadband) and heating is not locked out, a heating signal is generated, asking for hot water to be sent to the slab. 
If there is a call for cooling (ie, the slab temperature is above its setpoint plus a user-specified deadband) and cooling is not locked out, a cooling signal is generated, asing for cold water to be sent to the slab.  <p>


<p> When the slab is within its deadband, the user specifies whether the system should send no calls for heating or cooling (i.e. 'offwithindeadband' is set to true),
or whether it should continue to call for heating or cooling and then correct itself once the slab temperature goes out of range (i.e. 'offwithindeadband' is set to false).  <p>

<p> Heating is locked out if room air temperature is too hot (above a user-specified value, TAirHiSet), if night flush mode is on, or if cooling was on within a user-specified amount of time (TiHea). <p>
<p> 
Cooling is locked out if room air temperature is too cold (below a user-specified value, TAirLoSet), if chilled water return temperature is lower than a user-specified value 
(TWaLoSet, typically 55F or the chilled water supply temperature), or if heating was on within a user-specified amount of time (TiCoo, typically one hour).  <p>

</p>
</html>", revisions="<html>
<ul>
<li>
October 6, 2020, by Fiona Woods:<br/>
Updated description. 
</li>
</html>"),Icon(coordinateSystem(
        preserveAspectRatio=true,
        extent={{-100,-100},{100,100}}),graphics={
        Text(
          lineColor={0,0,255},
          extent={{-148,104},{152,144}},
          textString="%name"),
        Rectangle(extent={{-100,-100},{100,100}},
        lineColor={0,0,127},
        fillColor={255,255,255},
        fillPattern=FillPattern.Solid),
        Line(points={{-80,68},{-80,-80}}, color={192,192,192}),
        Polygon(points={{-80,90},{-88,68},{-72,68},{-80,90}},
          lineColor={192,192,192},
          fillColor={192,192,192},
          fillPattern=FillPattern.Solid),
        Line(points={{-90,0},{68,0}}, color={192,192,192}),
        Polygon(points={{90,0},{68,8}, {68,-8},{90,0}},
          lineColor={192,192,192}, fillColor={192,192,192},
          fillPattern=FillPattern.Solid),
        Line(points={{-80,0},{80,0}}),
        Line(points={{-80,-70},{-40,-70},{31,38}}),
        Polygon(lineColor = {191,0,0},
                fillColor = {191,0,0},
                pattern = LinePattern.None,
                fillPattern = FillPattern.Solid,
                points={{20,58},{100,-2},{20,-62},{20,58}}),
        Text(
          extent={{-72,78},{72,6}},
          lineColor={0,0,0},
        textString="R"),
        Text(
          extent={{226,60},{106,10}},
          lineColor={0,0,0},
          textString=DynamicSelect("", String(y, leftjustified=false, significantDigits=3)))}), Diagram(coordinateSystem(
          preserveAspectRatio=false, extent={{-100,-100},{100,100}}), graphics={
          Text(
          extent={{-92,92},{284,76}},
          lineColor={0,0,0},
          lineThickness=1,
          fontSize=9,
          horizontalAlignment=TextAlignment.Left,
          textStyle={TextStyle.Bold},
          textString="Control Plus Lockouts:
Full radiant control-
slab error,
deadband control,
and lockouts")}));
end ControlPlusLockouts;
