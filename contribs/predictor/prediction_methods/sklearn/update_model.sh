# 更新随机森林预测方法的预测模型及标签文件

# 定义predictor路径为变量
predictor_path="/opt/gridview/slurm/etc/luaconfig/predictor"

# 定义AI随机森林路径为变量
sklearn_path="/opt/gridview/slurm/etc/luaconfig/predictor/prediction_methods/sklearn"

# 获取python3执行路径
PYTHON_EXECUTABLE=$(awk -F'=' '/^python_executable=/ {print $2}' "$predictor_path/configuration")

# 获取当前时间
current_date=$(date +"%Y-%m-%d")

# 当新的jobHistory生成时,生成新的预测模型及标签文件
if [ -f "$predictor_path/jobHistory" ]; then

	# 生成新的预测模型及标签文件
	"$PYTHON_EXECUTABLE" $sklearn_path/generative_model.py

	# 获取 Python 脚本的退出状态码
	status_code=$?

else
	echo "Warning : File jobHistory does not exist, No new predictive model can be generated" >> $predictor_path/update.log
fi

# 检查退出状态码
if [ $status_code -eq 1 ]; then

	# 取消原有的标签
	if [ -L $sklearn_path/sklearn_label_encoders.pkl ]; then
		unlink $sklearn_path/sklearn_label_encoders.pkl
	fi

	# 取消原有的模型
	if [ -L $sklearn_path/sklearn_model.pkl ]; then
		unlink $sklearn_path/sklearn_model.pkl
	fi

else

	# 判断新预测模型及标签文件是否生成
	if [ -f "$sklearn_path/sklearn_label_encoders_$current_date.pkl" ]; then
	
		# 取消原有的标签
		if [ -L $sklearn_path/sklearn_label_encoders.pkl ]; then
			unlink $sklearn_path/sklearn_label_encoders.pkl
		fi
	
		# 链接新的标签
		ln -s $sklearn_path/sklearn_label_encoders_$current_date.pkl $sklearn_path/sklearn_label_encoders.pkl
	
		# 删除旧的标签
		find $sklearn_path/ -maxdepth 1 -type f -name 'sklearn_label_encoders_*' ! -name "sklearn_label_encoders_$current_date.pkl" -exec rm -f {} +
	fi
	
	if [ -f "$sklearn_path/sklearn_model_$current_date.pkl" ]; then
	
		# 取消原有的模型
		if [ -L $sklearn_path/sklearn_model.pkl ]; then
	        	unlink $sklearn_path/sklearn_model.pkl
		fi
	
		# 链接新的模型
	        ln -s $sklearn_path/sklearn_model_$current_date.pkl $sklearn_path/sklearn_model.pkl
	
		# 删除旧的模型
		find $sklearn_path/ -maxdepth 1 -type f -name 'sklearn_model_*' ! -name "sklearn_model_$current_date.pkl" -exec rm -f {} +
	fi

fi


