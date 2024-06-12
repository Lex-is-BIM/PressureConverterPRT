local params = Style.GetParameterValues().General
local mounting = params.MountingOptions
local rPipe=params.PipeDiameter/2
local fHeight = params.FittingHeight
local connSize = params.ConnectionSize
local rFitting = (connSize =="M") and 11.5 or 7.85

function circ(r)
    return CreateCircle2D(Point2D(0,0),r)
end

local lFitting = math.cos(math.asin(rFitting/rPipe))*rPipe+fHeight
local fitting = Subtract(
    Extrude(circ(rFitting),ExtrusionParameters(lFitting)),
    CreateRightCircularCylinder(rPipe,200):Shift(0,0,-100)
    :Rotate(CreateYAxis3D(),math.pi/2))

Style.SetDetailedGeometry(ModelGeometry():AddSolid(fitting))

