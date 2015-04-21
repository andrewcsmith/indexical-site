function setAddr(name) {
	var obj = document.getElementById('contactAddr-' + name);
	if (obj) {
		switch(name) {
			case 'b': name += 'eau'; break;
			case 'i': name += 'nfo'; break;
      case 'a': name += 'ndrew'; break;
      case 'd': name += 'avid'; break;
		}
		var dmn = new Array('org','.','al','ic','dex','in').reverse().toString();
		dmn = dmn.replace(/\,/g,'').replace(/(w)/g,'$1eb');
		obj.href = 'mailto:' + name + '@' + dmn;
	}
	return true;
}

// Email address obfuscator by Eric Meyer, http://meyerweb.com/
