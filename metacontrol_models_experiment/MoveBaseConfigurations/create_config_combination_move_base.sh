#!/bin/sh
qa_safety=0.0
qa_energy=0.0
echo "configs: [" > rosgraph_manipulator_config.yaml
global_path="../src-gen/"
#for controller_frequency
for i in 1 2 3
do
	if [ $i = 1 ]; then freq=15;fi
	if [ $i = 2 ]; then freq=20;fi
	if [ $i = 3 ]; then freq=25;fi
	freq_f5=$(echo "scale=1;$freq/5" |bc)
	freq_f2=$(echo "scale=1;$freq/2" |bc)
	#for max_vel_x
	for j in 1 2 3
	do
		if [ $j = 1 ]; then vel=0.3;fi
		if [ $j = 2 ]; then vel=0.5;fi
		if [ $j = 3 ]; then vel=0.75;fi
		acc=$(echo "scale=2;$vel*12" |bc)
		#for inflation_radius
		for k in 1 2 3
		do
			if [ $k = 1 ]; then rad=0.5;fi
			if [ $k = 2 ]; then rad=0.65;fi
			if [ $k = 3 ]; then rad=0.8;fi
			#for observation source
			for l in 1 2
			do
				if [ $l = 1 ]
				then 
					obs='scan'
					system_name="f${i}_v${j}_r${k}"
				fi
				if [ $l = 2 ]
				then
					obs='point_cloud'
					if ([ $i = 1 ] && [ $j = 1 ] && [ $k = 3 ]) ||
					   ([ $i = 1 ] && [ $j = 3 ] && [ $k = 1 ]) ||
					   ([ $i = 2 ] && [ $j = 1 ] && [ $k = 3 ]) 
					then
						system_name="f${i}_v${j}_r${k}_k"
					else
						continue
					fi
				fi
				relative_path=${system_name}/
				mkdir -p "${global_path}${relative_path}"
				file_name="${global_path}${relative_path}${system_name}.rossystem"
				touch ${file_name}
				echo "RosSystem { Name '${system_name}'  RosComponents (\n    ComponentInterface { name move_base \n        RosParameters{" > ${file_name}
				echo "            RosParameter 'controller_frequency' { RefParameter 'move_base.move_base.move_base.controller_frequency' value $freq}," >> ${file_name}
				echo "            RosParameter 'planner_frequency' { RefParameter 'move_base.move_base.move_base.planner_frequency' value $freq_f5}," >> ${file_name}
				echo "            RosParameter 'global/update_frequency' { RefParameter 'move_base.move_base.move_base.global_costmap/update_frequency' value $freq_f5}," >> ${file_name}
				echo "            RosParameter 'local/update_frequency' { RefParameter 'move_base.move_base.move_base.local_costmap/update_frequency' value $freq_f2}," >> ${file_name}
				echo "            RosParameter 'max_vel_x' { RefParameter 'move_base.move_base.move_base.TrajectoryPlannerROS/max_vel_x' value $vel}," >> ${file_name}
				echo "            RosParameter 'max_vel_y' { RefParameter 'move_base.move_base.move_base.TrajectoryPlannerROS/max_vel_y' value $vel}," >> ${file_name}
				echo "            RosParameter 'acc_lim_x' { RefParameter 'move_base.move_base.move_base.TrajectoryPlannerROS/acc_lim_x' value $acc}," >> ${file_name}
				echo "            RosParameter 'acc_lim_y' { RefParameter 'move_base.move_base.move_base.TrajectoryPlannerROS/acc_lim_y' value $acc}," >> ${file_name}
				echo "            RosParameter 'inflation_radius' { RefParameter 'move_base.move_base.move_base.local_costmap/inflater_layer/inflation_radius' value $rad}," >> ${file_name}
				echo "            RosParameter 'inflation_radius' { RefParameter 'move_base.move_base.move_base.global_costmap/inflater_layer/inflation_radius' value $rad}," >> ${file_name}
				echo "            RosParameter 'observation_sources' { RefParameter 'move_base.move_base.move_base.local_costmap/obstacles_layer/observation_sources' value $obs}," >> ${file_name}
				echo "            RosParameter 'observation_sources' { RefParameter 'move_base.move_base.move_base.global_costmap/obstacles_layer/observation_sources' value $obs}" >> ${file_name}
				echo "    }})" >> ${file_name}
				echo "    Parameters {" >> ${file_name}
				echo "        Parameter { name qa_safety type Double value $qa_safety}," >> ${file_name}
				echo "        Parameter { name qa_energy type Double value $qa_energy}}" >> ${file_name}
				echo "    }" >> ${file_name}
				echo "'${system_name}'," >>  rosgraph_manipulator_config.yaml
			done
		done
	done
done
sed -i '$ s/.$//' rosgraph_manipulator_config.yaml
echo "]" >> rosgraph_manipulator_config.yaml
echo $(tr -d '\n' < rosgraph_manipulator_config.yaml) > rosgraph_manipulator_config.yaml

