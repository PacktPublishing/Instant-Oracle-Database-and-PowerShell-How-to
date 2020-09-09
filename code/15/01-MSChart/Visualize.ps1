param (
[string]$outputFile = ".\Salaries.png",
[string]$outputFormat = "PNG",
[bool]$interactive = $true,
[bool]$openImage = $false)

function Get-SalaryData {
    Import-Module .\Oracle.DataAccess.psm1 -ArgumentList 2
    $sql = "select job_id, round(avg(salary), 2) avg_sal from hr.employees group by job_id order by job_id"
    Connect-TNS -TNS LOCALDEV -UserId HR -Password pass
    $dt = Get-DataTable -sql $sql
    Disconnect; $dt
}

$dt = Get-SalaryData

[void][Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
[void][Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms.DataVisualization")

$chart = New-object System.Windows.Forms.DataVisualization.Charting.Chart `
    -property @{ 
        Width=800; Height=400; BackColor=[System.Drawing.Color]::Transparent
        Dock = [System.Windows.Forms.DockStyle]::Fill
    }
$chartTitle = $chart.Titles.Add("Average Salaries by Job Code")
$chartTitle.Font = new-object drawing.font("calibri",18,[drawing.fontstyle]::Regular)

$chartArea = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea 
$chartArea.Area3DStyle.Enable3D = $true

$yAxis = $chartArea.AxisY
$yAxis.Title = "Salaries"
$yAxis.Interval = 5000
$yAxis.LabelAutoFitMinFontSize = 16
$yAxis.LabelStyle.Font = new-object drawing.font("calibri",14,[drawing.fontstyle]::Regular)
$yAxis.TitleFont = new-object drawing.font("calibri",18,[drawing.fontstyle]::Regular)

$xAxis = $chartArea.AxisX
$xAxis.Interval = 1
$xAxis.LabelAutoFitMinFontSize = 16
$xAxis.Title = "Job Codes"
$xAxis.LabelStyle.Font = new-object drawing.font("calibri",14,[drawing.fontstyle]::Regular)
$xAxis.TitleFont = new-object drawing.font("calibri",18,[drawing.fontstyle]::Regular)

$chart.ChartAreas.Add($ChartArea)

$series = $chart.Series.Add("Data") 
$series.XValueMember = "job_id"; $series.YValueMembers = "avg_sal"
$series["DrawingStyle"] = "Cylinder"
$chart.DataSource = $dt; $chart.DataBind()

$form = New-Object Windows.Forms.Form -property `
    @{ Text=$chartTitle.Text; Width=900; Height=600; 
    StartPosition = [Windows.Forms.FormStartPosition]::CenterScreen }
$form.controls.add($Chart) 

if ($outputFile -and $outputFormat) {
    $chart.SaveImage($outputFile, $outputFormat)    
    if ($openImage) { ii $outputFile }
}

if ($interactive) {
    $form.Add_Shown({$Form.Activate()}) 
    $form.ShowDialog()
    $form.Dispose()
}