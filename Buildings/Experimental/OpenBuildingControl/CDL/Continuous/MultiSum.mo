within Buildings.Experimental.OpenBuildingControl.CDL.Continuous;
block MultiSum
  "Sum of Reals: y = k[1]*u[1] + k[2]*u[2] + ... + k[n]*u[n]"

  parameter Integer nu(min=0) = 0 "Number of input connections"
    annotation (Dialog(connectorSizing=true), HideResult=true);
  parameter Real k[nu]=fill(1, nu) "Input gains";
  Interfaces.RealInput u[nu] "Connector of Real input signals"
    annotation (Placement(transformation(extent={{-120,70},{-80,-70}})));
  Interfaces.RealOutput y "Connector of Real output signal"
    annotation (Placement(transformation(extent={{100,-17},{134,17}})));
equation
  if size(u, 1) > 0 then
    y = k*u;
  else
    y = 0;
  end if;

  annotation (
  defaultComponentName="mulSum",
  Icon(graphics={   Rectangle(
        extent={{-100,-100},{100,100}},
        lineColor={0,0,127},
        fillColor={255,255,255},
        fillPattern=FillPattern.Solid),
                             Text(
          extent={{-200,-110},{200,-140}},
          lineColor={0,0,0},
          fillColor={255,213,170},
          fillPattern=FillPattern.Solid,
          textString="%k"), Text(
          extent={{-82,84},{82,-52}},
          lineColor={0,0,0},
          fillColor={255,213,170},
          fillPattern=FillPattern.Solid,
          textString="+"),
        Text(
          extent={{-144,150},{156,110}},
          textString="%name",
          lineColor={0,0,255})}),
    Documentation(info="<html>
<p>
The block outputs the scalar Real value <code>y</code> as sum of the 
elements of the Real input signal vector <code>u</code>, with gain 
factor <code>k</code>:
</p>
<p>
<code>y = k[1]*u[1] + k[2]*u[2] + ... k[N]*u[N]</code>;
</p>
<p>
The Real input connector is a vector. The vector dimension can be enlarged when
additional connection line is drawn. The connection is automatically connected 
to this new free index.
</p>

<p>
If no connection to the input connector <code>u</code> is present,
the output is set to zero: <code>y=0</code>.
</p>
<p>
The usage is demonstrated, e.g., in example
<a href=\"modelica://Buildings.Experimental.OpenBuildingControl.CDL.Continuous.Validation.MultiSum\">
Buildings.Experimental.OpenBuildingControl.CDL.Continuous.Validation.MultiSum</a>.
</p>
</html>",
revisions="<html>
<ul>
<li>
June 28, 2017, by Jianjun Hu:<br/>
First implementation, based on the implementation of the Modelica Standard 
Library. This is for
<a href=\"https://github.com/lbl-srg/modelica-buildings/issues/825\">issue 825</a>.
</li>
</ul>
</html>"));
end MultiSum;
