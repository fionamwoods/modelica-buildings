within Buildings.Experimental.NaturalVentilation.Window;
block WindowControl "Controls window based on cooling needs"
  parameter Real minOpe(min=0,
  max=1)=
      0.15 "Minimum % open for window";
  parameter Real TiConInt(min=0,
    final unit="s",
    final displayUnit="s",
    final quantity="Time")=300  "Time constant for integral term";
  parameter Real kConPro(min=0,max=10)=0.1 "Constant for proportional term";
  Controls.OBC.CDL.Interfaces.RealInput TRooSet
    "Room setpoint for window to maintain" annotation (Placement(
        transformation(extent={{-140,10},{-100,50}}), iconTransformation(
          extent={{-140,-48},{-100,-8}})));
  Controls.OBC.CDL.Interfaces.RealInput TRooMea "Measured room air temperature"
    annotation (Placement(transformation(extent={{-140,-50},{-100,-10}}),
        iconTransformation(extent={{-140,30},{-100,70}})));
  Controls.OBC.CDL.Interfaces.RealOutput yWinOpeReq
    "Window percent open request per PI loop" annotation (Placement(
        transformation(extent={{200,-22},{240,18}}), iconTransformation(
          extent={{100,-18},{140,22}})));
  Controls.OBC.CDL.Continuous.Hysteresis hys(uLow=0,             uHigh=minOpe)
    "Test if window signal is greater than minimum opening percentage"
    annotation (Placement(transformation(extent={{20,-2},{40,18}})));
  Controls.OBC.CDL.Logical.Switch swi
    "Output zero if position is less than minimum opening amount"
    annotation (Placement(transformation(extent={{58,0},{78,20}})));
  Controls.Continuous.LimPID conPID(
    controllerType=Modelica.Blocks.Types.SimpleController.PI,
    k=1,
    Ti=TiConInt,
    yMin=0.15,
    wp=kConPro,
    initType=Modelica.Blocks.Types.InitPID.InitialState,
    reverseActing=false)
    annotation (Placement(transformation(extent={{-20,0},{0,20}})));
  Controls.OBC.CDL.Continuous.Sources.Constant winClo(k=0)
    "Signal if window is 0% open"
    annotation (Placement(transformation(extent={{22,-42},{42,-22}})));
equation
  connect(swi.u2, hys.y)
    annotation (Line(points={{56,10},{50,10},{50,8},{42,8}},
                                               color={255,0,255}));
  connect(swi.y, yWinOpeReq) annotation (Line(points={{80,10},{90,10},{90,-2},
          {220,-2}}, color={0,0,127}));
  connect(TRooSet, conPID.u_s) annotation (Line(points={{-120,30},{-72,30},{-72,
          10},{-22,10}}, color={0,0,127}));
  connect(TRooMea, conPID.u_m)
    annotation (Line(points={{-120,-30},{-10,-30},{-10,-2}}, color={0,0,127}));
  connect(conPID.y, hys.u)
    annotation (Line(points={{1,10},{10,10},{10,8},{18,8}}, color={0,0,127}));
  connect(conPID.y, swi.u1) annotation (Line(points={{1,10},{14,10},{14,42},{50,
          42},{50,18},{56,18}}, color={0,0,127}));
  connect(winClo.y, swi.u3) annotation (Line(points={{44,-32},{52,-32},{52,2},
          {56,2}}, color={0,0,127}));
  annotation (defaultComponentName = "winCon", Documentation(info="<html>
  This block determines the window control signal, ie what % the window is called to be open.
  <p>The window position is modulated with direct-acting PI control, with a user-specified constant 
  for the proportional term (kConPro, typically 0.1) and time constant for the integral term (TiConInt, typically 5 minutes). 
  <p>The user also specifies a minimum opening position (minOpe, typically 0.15)- if the window is to be opened, it must be opened at least this amount. 
  If the PI control loop calls for a window position that is less than this minimum value, the window remains closed. 
  
<p>
</p>
</html>", revisions="<html>
<ul>
<li>
October 6, 2020, by Fiona Woods:<br/>
Updated description. 
</li>
</html>"),Icon(coordinateSystem(preserveAspectRatio=false), graphics={
        Rectangle(
          extent={{-100,100},{100,-100}},
          lineColor={162,29,33},
          lineThickness=1,
          fillColor={255,255,255},
          fillPattern=FillPattern.Solid),
        Line(
          points={{-100,60},{-100,-60},{-20,-88},{-20,40},{-100,60},{-20,60}},
          color={162,29,33},
          thickness=1),
        Line(
          points={{20,60},{100,60},{100,-62},{20,-88},{20,40},{98,60},{100,58}},
          color={162,29,33},
          thickness=1),
        Line(
          points={{-20,60},{20,60}},
          color={162,29,33},
          thickness=1),
        Line(
          points={{-16,-60},{20,-60},{-20,-60}},
          color={162,29,33},
          thickness=1),
        Line(
          points={{-60,50},{-60,-74}},
          color={162,29,33},
          thickness=1),
        Line(
          points={{60,50},{60,-74}},
          color={162,29,33},
          thickness=1),
        Line(
          points={{-100,0},{-20,-20}},
          color={162,29,33},
          thickness=1),
        Line(
          points={{20,-20},{100,0}},
          color={162,29,33},
          thickness=1),
        Text(
          lineColor={0,0,255},
          extent={{-150,100},{150,140}},
          textString="%name")}),
                          Diagram(coordinateSystem(preserveAspectRatio=false, extent={
            {-100,-300},{200,100}}), graphics={Text(
          extent={{-92,92},{308,60}},
          lineColor={0,0,0},
          lineThickness=1,
          fontSize=9,
          horizontalAlignment=TextAlignment.Left,
          textStyle={TextStyle.Bold},
          textString="Window Control:
Modulates window with a PID loop.
If window position is below user-specified minimum,
window is treated as closed. 
")}));
end WindowControl;
