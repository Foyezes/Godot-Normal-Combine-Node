# **Normal Combine node for Godot 4**

This is an addon for Godot 4.2+ that adds a `NormalCombine` node to the visual shader system. This allows for combining two normal maps using the UDN, Whiteout, RNM and Unity blending methods.

![image](https://github.com/user-attachments/assets/bf99915d-4ba0-491c-8b0f-a3384aa219d8) 

# Methods

For the Whiteout method, I followed Substance 3D Designer. I got the AddSub blending method from [this article](https://campi3d.com/External/MariExtensionPack/userGuide5R7/CustomBlendModes.html#AddSub2). The UDN method is the same as the Whiteout method, except it uses the Z channel from normal map 1 directly, without any calculation with normal map 2. For RNM and Unity, I followed [this Self Shadow article ](https://blog.selfshadow.com/publications/blending-in-detail/). Although the Self Shadow blog has the UDN and Whiteout methods, it requires unpacking and repacking the normal maps.

![image](https://github.com/user-attachments/assets/5be629bb-b68f-4d5e-834b-e68ba9982ca9)


## UDN

The X and Y channels are blended using the AddSub method, like in Substance 3D Designer. I used the Z channel from Normal Map 1 directly to make it cheaper than Whiteout.

	return vec3(n1.rg + ((n2.rg - 0.5)), n1.z);

## Whiteout

The X and Y channels are blended using the AddSub method, the Z channels are being multiplied, like in Substance 3D Designer.

	return vec3(n1.rg + ((n2.rg - 0.5)), n1.z * n2.z);

## RNM

I copied the RNM blending method shown in Self Shadow.

	vec3 n1 = n1_in * vec3(2, 2, 2) + vec3(-1, -1, 0);
	vec3 n2 = n2_in * vec3(-2, -2, 2) + vec3(1, 1, -1);
	return vec3(n1 * dot(n1, n2) / n1.z - n2) * 0.5 + 0.5;

## Unity

I copied the Unity blending method shown in Self Shadow.

	vec3 n1 = n1_in * 2.0 - 1.0;
	vec3 n2 = n2_in * 2.0 - 1.0;
					
	mat3 nBasis = mat3(
		vec3(n1.z, n1.y, -n1.x),
		vec3(n1.x, n1.z, -n1.y),	
		vec3(n1.x, n1.y, n1.z));
					
	return vec3(n2.x * nBasis[0] + n2.y * nBasis[1] + n2.z * nBasis[2]) * 0.5 + 0.5;

# Performance

The difference between UDN and Whiteout are only that for UDN, the Z channel calculation is skipped. So UDN is slightly cheaper than Whiteout but it can be negligible. RNM is more costly as it needs to reorient the normal maps. At last Unity is most costly as it uses matrices. It's recommended to use UDN or Whiteout for most use cases, and RNM for detail oriented blending.

There is option to skip normalization of the blended result. If your normal map looks ok without normalising, you can turn it off for better performance.

# Installation

Extract the zip file and copy the folder to your project. You'll need to restart the editor for the node to appear in visual shader.
Alternatively, you can make a new gdscript file and copy and paste the code.
