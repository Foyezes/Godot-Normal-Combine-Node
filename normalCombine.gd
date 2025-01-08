@tool
extends VisualShaderNodeCustom
class_name VisualShaderNodeNormalCombine

func _get_name():
	return "NormalCombine"
	
func _get_category():
	return "Color"
	
func _get_description():
	return "Combine normal maps"

func _get_output_port_count():
	return 1

func _get_return_icon_type():
	return VisualShaderNode.PORT_TYPE_VECTOR_3D
	
func _get_output_port_type(port):
	return VisualShaderNode.PORT_TYPE_VECTOR_3D

func _get_output_port_name(port):
	return ""

func _get_input_port_count():
	return 2

func _get_input_port_name(port):
	match port:
		0:
			return "Normal 1"
		1:
			return "Normal 2"
			
func _get_input_port_type(port):
	match port:
		0:
			return VisualShaderNode.PORT_TYPE_VECTOR_3D
		1:
			return VisualShaderNode.PORT_TYPE_VECTOR_3D

func _get_property_count():
	return 2
	
func _get_property_name(index):
	match index:
		0:
			return "Method"
		1:
			return "Normalised"

func _get_property_options(index):
	match index:
		0:
			return ["UDN(Fastest)", "Whiteout(Fast)", "RNM(Slow)", "Unity(Slowest)"]
		1:
			return ["Yes(Default)", "No"]

func _get_propert_default_index(index):
	match index:
		0:
			return 0
		1:
			return 0

func _get_global_code(mode):
	var method = get_option_index(0)
	match method:
		0:
			return """
			vec3 UDN(vec3 n1, vec3 n2){
				return vec3(n1.rg + ((n2.rg - 0.5)), n1.z);
			}
			"""	
		1:
			return """
			vec3 whiteout(vec3 n1, vec3 n2){
				return vec3(n1.rg + ((n2.rg - 0.5)), n1.z * n2.z);
			}
			"""
		2:
			return """
			vec3 RNM(vec3 n1_in, vec3 n2_in){
				vec3 n1 = n1_in * vec3(2, 2, 2) + vec3(-1, -1, 0);
				vec3 n2 = n2_in * vec3(-2, -2, 2) + vec3(1, 1, -1);
				return vec3(n1 * dot(n1, n2) / n1.z - n2) * 0.5 + 0.5;
			}
			"""
		3:
			return """
			vec3 unity(vec3 n1_in, vec3 n2_in){
				
				vec3 n1 = n1_in * 2.0 - 1.0;
				vec3 n2 = n2_in * 2.0 - 1.0;
				
				mat3 nBasis = mat3(
				vec3(n1.z, n1.y, -n1.x),
				vec3(n1.x, n1.z, -n1.y),
				vec3(n1.x, n1.y, n1.z));
				
				return vec3(n2.x * nBasis[0] + n2.y * nBasis[1] + n2.z * nBasis[2]) * 0.5 + 0.5;
			}
			"""
			
func _get_code(input_vars, output_vars, mode, type):
	var method = get_option_index(0)
	var normalized = get_option_index(1)
	
	match [method, normalized]:
		[0, 1]:
			return output_vars[0] + "=UDN(%s, %s);" % [input_vars[0], input_vars[1]]
		[0, 0]:
			return output_vars[0] + "=normalize(UDN(%s, %s));" % [input_vars[0], input_vars[1]]
		[1, 1]:
			return output_vars[0] + "=whiteout(%s, %s);" % [input_vars[0], input_vars[1]]
		[1, 0]:
			return output_vars[0] + "=normalize(whiteout(%s, %s));" % [input_vars[0], input_vars[1]]
		[2, 1]:
			return output_vars[0] + "=RNM(%s, %s);" % [input_vars[0], input_vars[1]]
		[2, 0]:
			return output_vars[0] + "=normalize(RNM(%s, %s));" % [input_vars[0], input_vars[1]]
		[3, 1]:
			return output_vars[0] + "=unity(%s, %s);" % [input_vars[0], input_vars[1]]
		[3, 0]:
			return output_vars[0] + "=normalize(unity(%s, %s));" % [input_vars[0], input_vars[1]]
