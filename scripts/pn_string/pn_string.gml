/// @description string_parse(string)
/// @param string
function string_parse(_string, _reals)
{
	//  Returns an array containing all substring elements within a given string which are separated by "|".
	//
	//  eg. string_parse("0|cat|1|dog", false)
	//      returns an array [ "0", "cat", "1", "dog" ]
	//	and
	//		string_parse("0|¤cat|1|¤dog", true)
	//		returns an array [ 0, "cat", 1, "dog ]
	//
    //      str         elements, string
	//		reals		whether or not to treat every item as a real unless specified as a string using the "¤" prefix, boolean
	//
    /// GMLscripts.com/license
	if (_reals)
	{
		var array = string_parse(_string, false), i = 0;
		repeat (array_length(array))
		{
			array[i] = string_copy(array[i], 1, 1) == "¤" ? string_copy(array[i], 2, string_length(array[i]) - 1) : real(array[i]);
			i++;
		}
	}
	else
	{
		var str = _string, array = [], temp;
	    while (string_length(str) != 0)
		{
			temp = string_pos("|", str);
	        if (temp)
			{
				if (temp != 1) array[@ array_length(array)] = string_copy(str, 1, temp - 1);
				str = string_copy(str, temp + 1, string_length(str));
	        }
			else
			{
				array[@ array_length(array)] = str;
	            str = "";
	        }
	    }
	}
	return (array)
}