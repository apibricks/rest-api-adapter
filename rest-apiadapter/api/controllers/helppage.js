"use strict";
/**
 * API Controller which handles requests for help requests.
 * The page returned is a HTML representation of the swagger file.
 * author: Tobias Freundorfer (https://github.com/tfreundo)
 */
var fs = require("fs");

exports.getPage = function (req, res) {
	fs.readFile("./html/inline-index.html", function (err, html) {
		if (err) {
			console.log(err);

			fs.readFile("./html/oops.html", function (err, oopshtml) {
				if (err) {
					console.log(err);
				} else {
					res.writeHeader(503, {
						"Content-Type": "text/html"
					});
					res.write(oopshtml);
					res.end();

				}
			});
		} else {
			res.writeHeader(200, {
				"Content-Type": "text/html"
			});
			res.write(html);
			res.end();
		}

	});
}
