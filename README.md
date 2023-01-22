<p align="right">
<a href="https://discord.gg/KnJGY9S">
<img src="https://github.com/fenix-hub/ColoredBadges/blob/master/svg/social/discord.svg" alt="react" style="vertical-align:top; margin:6px 4px">
</a>
</p>

# Notice, plugin under refactoring
**This plugin is under refactoring an maintenance. The next official release will contain multiple updates and upgrades.**\
**If you encounter any bug, please contact me on Discord.**


<img src="addons/easy_charts/icon.png" align="left" width="64" height="64">

# Easy Charts
A library of Charts plotted in Control, 2D and 3D nodes to visualize general purpose datasets.  

## How does it work?
There is a [WIKI](https://github.com/fenix-hub/godot-engine.easy-charts/wiki) with some tutorials, even if it is a work in progress.  
You can also find practical examples in `addons/easy_charts/examples/`.

# Available Charts and when to use them    
This library offers a set of charts for each main Godot Node:   
- **Control Charts:** Fast Charts plotted in a Control Node. They offer basic Control properties, such as Margins, size inheritance and control. No animations, best suited for UIs that rely on Control Node structures.
- **2D Charts:** plotted in 2D Nodes. They offer additional tools, such as animations. They can be used to implement more aesthetic charts in 2D contexts. Compatibility not guaranteed in Canvas and Control nodes.
- **3D Charts:** Plotted using 3D nodes, but can be used both in 2D and 3D spaces. They offer the possibility to plot 3D datasets, which are common in machine learning contexts or just data analysis. A Camera Control will also be available, which can be used to move around the chart.

### Available Charts
|              | Control | 2D | 3D |
|--------------|---------|----|----|
| ScatterChart | ✅ | ❌ | ❌ |
| LineChart | ✅ | ❌ | ❌ |
| BarChart | ✅ | ❌ | ❌ |
| AreaChart | ❌ | ❌ | ❌ |
| PieChart | ❌ | ❌ | ❌ |
| RadarChart | ❌ | ❌ | ❌ |
| BubbleChart | ❌ | ❌ | ❌ |
| DonutChart | ❌ | ❌ | ❌ |
| ParliamentChart | ❌ | ❌ | ❌ |
| SunburstChart | ❌ | ❌ | ❌ |

### Some Examples    
![example_LineChart_realtime](imgs/real_time_line.gif)
![example_Piechart](imgs/pie_chart_realtime.gif)
![exampleradar](imgs/radar.png)
![example01](imgs/scatter.gif)
![example03](imgs/example03.gif)  

##### Some references for charts and plots
[Flourish](https://app.flourish.studio/projects)   
[Chart.js](https://www.chartjs.org/samples/latest/)   
[Google Charts](https://developers.google.com/chart)   

# ⚠️ Disclaimer
This addon was built for a **personal use** intention. It was released as an open source plugin in the hope that it could be useful to the Godot Engine Community.  
As a "work in progress" project, there is *no warranty* for any eventual issue and bug that may broke your project.  
I don't assume any responsibility for possible corruptions of your project. It is always advisable to keep a copy of your project and check any changes you make in your Github repository.  
-----------------
> This text file was created via [TextEditor Integration](https://github.com/fenix-hub/godot-engine.text-editor) inside Godot Engine's Editor.
> This text file was pushed  via [GitHub Integration](https://github.com/fenix-hub/godot-engine.github-integretion) inside Godot Engine's Editor.
