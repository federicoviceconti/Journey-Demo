# 🚗 journey_demo

Prototype of journey planner using Flutter framework. Using OpenCharge API for retrieving CU data.

## 🗒 Some notes about the app

- The blue path represent the solution, which the car use the reach the destination. 
- The yellow boxes are the node "walked", in order to get the solution.
- The green boxes represent the charging stations.
- The app grid could be changed at the [following file](https://github.com/federicoviceconti/Journey-Demo/blob/main/lib/notifier/grid_notifier.dart).

## ❤️ Demo screens

**Grid 10x12**: In this example there aren't Charging Units to reach, but only a start and an end point.

<img src="https://github.com/federicoviceconti/Journey-Demo/blob/main/demo/grid_astar_start.png" alt="mockup demo app grid start" width="200"> <img src="https://github.com/federicoviceconti/Journey-Demo/blob/main/demo/grid_astar_end.png" alt="mockup demo app grid end" width="200">

**Grid 15x15**: In this example there are two Charging Units (green box) to reach before the end.

<img src="https://github.com/federicoviceconti/Journey-Demo/blob/main/demo/grid_astar_withcu.png" alt="mockup demo app with cu" width="200">

## 🙋‍♂️ Credits
- A* Grid: you can find more info about the A-Star search algorithm into the [Wikipedia page](https://en.wikipedia.org/wiki/A*_search_algorithm).
- CU Data: charging stations data are provided by [Open Charge API](https://openchargemap.org/site/develop/api).
