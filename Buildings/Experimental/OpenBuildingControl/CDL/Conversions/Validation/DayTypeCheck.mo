within Buildings.Experimental.OpenBuildingControl.CDL.Conversions.Validation;
model DayTypeCheck
  "Model to validate blocks IsWorkingDay, IsNonWorkingDay, IsHoliday"
extends Modelica.Icons.Example;

  Buildings.Experimental.OpenBuildingControl.CDL.Conversions.IsWorkingDay isWorDay
  "Block to check if it is working day"
    annotation (Placement(transformation(extent={{20,30},{40,50}})));
  Buildings.Experimental.OpenBuildingControl.CDL.Conversions.IsNonWorkingDay isNonWorDay
  "Block to check if it is non-working day"
    annotation (Placement(transformation(extent={{20,-10},{40,10}})));
  Buildings.Experimental.OpenBuildingControl.CDL.Conversions.IsHoliday isHoliday
  "Block to check if it is holiday day"
    annotation (Placement(transformation(extent={{20,-50},{40,-30}})));
  Buildings.Experimental.OpenBuildingControl.CDL.Discrete.DayType dayTypSat(iStart=6)
    "Model that outputs the type of the day, starting with Saturday"
    annotation (Placement(transformation(extent={{-80,-10},{-60,10}})));
equation
  connect(dayTypSat.y[1], isNonWorDay.u)
    annotation (Line(points={{-59,0},{-40,0},{-20,0},{18,0}}, color={0,127,0}));
  connect(dayTypSat.y[1], isHoliday.u)
    annotation (Line(points={{-59,0},{-40,0},{-20,0},{-20,-40},{18,-40}},
      color={0,127,0}));
  connect(dayTypSat.y[1], isWorDay.u)
    annotation (Line(points={{-59,0},{-20,0},{-20,40},{18,40}},
      color={0,127,0}));
  annotation (
__Dymola_Commands(file="modelica://Buildings/Resources/Scripts/Dymola/Experimental/OpenBuildingControl/CDL/Conversions/Validation/DayTypeCheck.mos"
        "Simulate and plot"),
     experiment(StartTime=0, StopTime=1814400, Tolerance=1E-6),
    Documentation(info="<html>
<p>
This example validates the bocks <code>IsWorkingDay</code>, 
<code>IsNonWorkingDay</code>, <code>IsHoliday</code>. The instance 
<code>dayTypSat</code> generates DayType signals for three consecutive weeks, 
with five working and two non-working days. The first day is Saturady, which
is a non-working day.
</p>
</html>",
revisions="<html>
<ul>
<li>
July 17, 2017, by Jianjun Hu:<br/>
First CDL implementation.
</li>
</ul>
</html>"));
end DayTypeCheck;