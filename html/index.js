garageOpen = false;
dropdownDiv = false;
choosedCar = null;
garageVehicles = [];
choosedVehData = [];
currentGarageType = null;
vehicleLogs = [];
useCarImg = false;
useCustomCarImg = false;
garageVehicles2 = [];
window.addEventListener('message', function(event) {
    ed = event.data;
    if (ed.action === "VehicleList") {
		currentGarageType = ed.garageType;
		garageOpen = true;
		choosedCar = null;
		// Button All
		document.getElementById("MDRSBottomDivTopButtonAll").classList.add("MDRSBottomDivTopButtonActive");
		document.getElementById("MDRSBottomDivTopButtonAll").classList.remove("MDRSBottomDivTopButtonInactive");
		// Button Personal
		document.getElementById("MDRSBottomDivTopButtonPersonal").classList.remove("MDRSBottomDivTopButtonActive");
		document.getElementById("MDRSBottomDivTopButtonPersonal").classList.add("MDRSBottomDivTopButtonInactive");
		// Button Job
		document.getElementById("MDRSBottomDivTopButtonJob").classList.remove("MDRSBottomDivTopButtonActive");
		document.getElementById("MDRSBottomDivTopButtonJob").classList.add("MDRSBottomDivTopButtonInactive");
		// document.getElementById("bgEffect").style.display = "block";
		$("#mainDiv").fadeIn();
		document.getElementById("mainDiv").style.display = "flex";
		document.getElementById("MDLeftSide").style.opacity = "0";
		let label = ed.garageLabel;
		if (label.length > 12) {
			label = label.slice(0, 12) + "...";
		}
		document.getElementById("garageLabel").innerHTML=label;
		document.getElementById("MDRSBottomDivBottom").innerHTML="";
		let parkedVehNum = 0;
		garageVehicles = ed.vehicles;
		garageVehicles2 = [...new Set(ed.vehicles.map((vehicle) => {return vehicle}))];
		useCarImg = ed.useCarImg;
		useCustomCarImg = ed.useCustomCarImg;
		garageVehicles.forEach(function(vehData, index) {
			// Logs
			vehicleLogs[vehData.plate] = vehData.logs;
			let status;
			let isDepotPrice1 = false;
			let divStyle = "MDRSBDBCarDivInactive";
			let divStyleBorderBottom = "MDRSBDBCarDivBottomBorderInactive";
			if (vehData.state === 0) {
				if (vehData.depotPrice && vehData.depotPrice > 0) {
					isDepotPrice1 = true;
					divStyle = "MDRSBDBCarDivDepot";
					if (vehData.type === "public") {
						status = "Depot";
						divStyleBorderBottom = "MDRSBDBCarDivBottomBorderDepot";
					} else if (vehData.type === "depot") {
						status = "$" + vehData.depotPrice.toFixed(0);
						divStyleBorderBottom = "MDRSBDBCarDivBottomBorderDepot";
					} else {
						status = "Out";
						divStyleBorderBottom = "MDRSBDBCarDivBottomBorderOut";
					}
				} else {
					divStyle = "MDRSBDBCarDivOut";
					divStyleBorderBottom = "MDRSBDBCarDivBottomBorderOut";
					status = "Out";
				}
			} else if (vehData.state === 1) {
				if (vehData.depotPrice && vehData.depotPrice > 0) {
					isDepotPrice1 = true;
					if (vehData.type === "depot") {
						status = "$" + vehData.depotPrice.toFixed(0);
						divStyle = "MDRSBDBCarDivDepot";
						divStyleBorderBottom = "MDRSBDBCarDivBottomBorderDepot";
					} else if (vehData.type === "public") {
						status = "Depot";
						divStyle = "MDRSBDBCarDivDepot";
						divStyleBorderBottom = "MDRSBDBCarDivBottomBorderDepot";
					} else {
						status = "Stored";
						divStyle = "MDRSBDBCarDivInactive";
						divStyleBorderBottom = "MDRSBDBCarDivBottomBorderInactive";
						parkedVehNum = parkedVehNum + 1;
					}
				} else {
					status = "Stored";
					divStyle = "MDRSBDBCarDivInactive";
					divStyleBorderBottom = "MDRSBDBCarDivBottomBorderInactive";
					parkedVehNum = parkedVehNum + 1;
				}
			} else if (vehData.state === 2) {
				status = "Impound";
			}
			let plateImg = null;
			let plateTextColor = null;
			if (vehData.plateIndex === 0) {
				plateImg = "files/plate1.png";
				plateTextColor = "blue";
			} else if (vehData.plateIndex === 1) {
				plateImg = "files/plate2.png";
				plateTextColor = "yellow;"
			} else if (vehData.plateIndex === 2) {
				plateImg = "files/plate3.png";
				plateTextColor = "yellow";
			} else if (vehData.plateIndex === 3) {
				plateImg = "files/plate4.png";
				plateTextColor = "darkblue";
			} else if (vehData.plateIndex === 4) {
				plateImg = "files/plate1.png";
				plateTextColor = "darkblue";
			} else if (vehData.plateIndex === 5) {
				plateImg = "files/plate6.png";
				plateTextColor = "blue";
			}
			let vehLabel = vehData.vehicleLabel;
			if (vehLabel.length > 15) {
				vehLabel = vehLabel.slice(0, 15) + "...";
			}
			if (useCarImg) {
				checkIfImageExists(`https://docs.fivem.net/vehicles/${vehData.vehicle}.webp`, (exists) => {
					if (exists) {
						var vehiclesHTML = `
						<div class="MDRSBDBCarDiv ${divStyle}" id="MDRSBDBCarDiv-${vehData.plate}" onclick="clFunc('chooseCar', '${vehData.vehicle}', '${vehData.plate}', '${status}', '${vehData.engine}', '${vehData.body}', '${vehData.fuel}', '', '${vehData.index}', '${vehData.type}', '${vehData.depotPrice}')">
							<div id="MDRSBDBCarDivTop">
								<div id="MDRSBDBCarDivTopRectangle"></div><div id="MDRSBDBCarDivTopShared" class="${vehData.shared}"><i style="opacity: 0.42;" class="fas fa-key"></i></div>
								<img src="https://docs.fivem.net/vehicles/${vehData.vehicle}.webp" style="width: 8vw; position: relative; padding-top: 2vw;">
								<div id="MDRSBDBCarDivTopPlate" style="background-image: url(${plateImg}); color: ${plateTextColor};"><h4>${vehData.plate}</h4></div>
							</div>
							<div id="MDRSBDBCarDivBottom"><h4>${vehLabel}</h4><h4>${status}</h4></div>
							<div class="MDRSBDBCarDivBottomBorder ${divStyleBorderBottom}" id="MDRSBDBCarDivBottomBorder-${vehData.plate}"></div>
						</div>`;
						appendHtml(document.getElementById("MDRSBottomDivBottom"), vehiclesHTML);
					} else {
						if (useCustomCarImg) {
							var vehiclesHTML = `
							<div class="MDRSBDBCarDiv ${divStyle}" id="MDRSBDBCarDiv-${vehData.plate}" onclick="clFunc('chooseCar', '${vehData.vehicle}', '${vehData.plate}', '${status}', '${vehData.engine}', '${vehData.body}', '${vehData.fuel}', '', '${vehData.index}', '${vehData.type}', '${vehData.depotPrice}')">
								<div id="MDRSBDBCarDivTop">
									<div id="MDRSBDBCarDivTopRectangle"></div><div id="MDRSBDBCarDivTopShared" class="${vehData.shared}"><i style="opacity: 0.42;" class="fas fa-key"></i></div>
									<img src="cars/${vehData.vehicle}.png" style="width: 8vw; position: relative; padding-top: 2vw;">
									<div id="MDRSBDBCarDivTopPlate" style="background-image: url(${plateImg}); color: ${plateTextColor};"><h4>${vehData.plate}</h4></div>
								</div>
								<div id="MDRSBDBCarDivBottom"><h4>${vehLabel}</h4><h4>${status}</h4></div>
								<div class="MDRSBDBCarDivBottomBorder ${divStyleBorderBottom}" id="MDRSBDBCarDivBottomBorder-${vehData.plate}"></div>
							</div>`;
							appendHtml(document.getElementById("MDRSBottomDivBottom"), vehiclesHTML);
						} else {
							var vehiclesHTML = `
							<div class="MDRSBDBCarDiv ${divStyle}" id="MDRSBDBCarDiv-${vehData.plate}" onclick="clFunc('chooseCar', '${vehData.vehicle}', '${vehData.plate}', '${status}', '${vehData.engine}', '${vehData.body}', '${vehData.fuel}', '', '${vehData.index}', '${vehData.type}', '${vehData.depotPrice}')">
								<div id="MDRSBDBCarDivTop">
									<div id="MDRSBDBCarDivTopRectangle"></div><div id="MDRSBDBCarDivTopShared" class="${vehData.shared}"><i style="opacity: 0.42;" class="fas fa-key"></i></div>
									<img src="files/car.png" style="width: 6vw; position: relative; padding-top: 2vw;">
									<div id="MDRSBDBCarDivTopPlate" style="background-image: url(${plateImg}); color: ${plateTextColor};"><h4>${vehData.plate}</h4></div>
								</div>
								<div id="MDRSBDBCarDivBottom"><h4>${vehLabel}</h4><h4>${status}</h4></div>
								<div class="MDRSBDBCarDivBottomBorder ${divStyleBorderBottom}" id="MDRSBDBCarDivBottomBorder-${vehData.plate}"></div>
							</div>`;
							appendHtml(document.getElementById("MDRSBottomDivBottom"), vehiclesHTML);
						}
					}
				});
			} else {
				var vehiclesHTML = `
				<div class="MDRSBDBCarDiv ${divStyle}" id="MDRSBDBCarDiv-${vehData.plate}" onclick="clFunc('chooseCar', '${vehData.vehicle}', '${vehData.plate}', '${status}', '${vehData.engine}', '${vehData.body}', '${vehData.fuel}', '', '${vehData.index}', '${vehData.type}', '${vehData.depotPrice}')">
					<div id="MDRSBDBCarDivTop">
						<div id="MDRSBDBCarDivTopRectangle"></div><div id="MDRSBDBCarDivTopShared" class="${vehData.shared}"><i style="opacity: 0.42;" class="fas fa-key"></i></div>
						<img src="files/car.png" style="width: 6vw; position: relative; padding-top: 2vw;">
						<div id="MDRSBDBCarDivTopPlate" style="background-image: url(${plateImg}); color: ${plateTextColor};"><h4>${vehData.plate}</h4></div>
					</div>
					<div id="MDRSBDBCarDivBottom"><h4>${vehLabel}</h4><h4>${status}</h4></div>
					<div class="MDRSBDBCarDivBottomBorder ${divStyleBorderBottom}" id="MDRSBDBCarDivBottomBorder-${vehData.plate}"></div>
				</div>`;
				appendHtml(document.getElementById("MDRSBottomDivBottom"), vehiclesHTML);
			}
		});
		document.getElementById("MDRSTDCDiv2").innerHTML=`<div id="MDRSTDCDiv2Inside"><div id="MDRSTDCDiv2I"></div></div><h4 id="MDRSTDCDiv2H41">${parkedVehNum}</h4>/<h4 id="MDRSTDCDiv2H42">${ed.vehNum}</h4>`;
	} else if (ed.action === "textUI") {
		if (ed.show) {
			if (ed.key) {
				document.getElementById("TUKeyDivInside").innerHTML=ed.key;
			}
			document.getElementById("textUIH4").innerHTML=ed.text;
			$("#textUI").fadeIn().css({bottom: "-10%", position:'absolute', display:'flex'}).animate({bottom: "4%"}, 800, function() {});
		} else {
			$("#textUI").fadeIn().css({bottom: "4%", position:'absolute', display:'none'}).animate({bottom: "-10%"}, 800, function() {});
		}
	} else if (ed.action === "VehicleListJob") {
		currentGarageType = ed.garageType;
		garageOpen = true;
		choosedCar = null;
		// Button All
		document.getElementById("MDRSBottomDivTopButtonAll").classList.add("MDRSBottomDivTopButtonActive");
		document.getElementById("MDRSBottomDivTopButtonAll").classList.remove("MDRSBottomDivTopButtonInactive");
		// Button Personal
		document.getElementById("MDRSBottomDivTopButtonPersonal").classList.remove("MDRSBottomDivTopButtonActive");
		document.getElementById("MDRSBottomDivTopButtonPersonal").classList.add("MDRSBottomDivTopButtonInactive");
		// Button Job
		document.getElementById("MDRSBottomDivTopButtonJob").classList.remove("MDRSBottomDivTopButtonActive");
		document.getElementById("MDRSBottomDivTopButtonJob").classList.add("MDRSBottomDivTopButtonInactive");
		// document.getElementById("bgEffect").style.display = "block";
		$("#mainDiv").fadeIn();
		document.getElementById("mainDiv").style.display = "flex";
		document.getElementById("MDLeftSide").style.opacity = "0";
		let label = ed.garageLabel;
		if (label.length > 12) {
			label = label.slice(0, 12) + "...";
		}
		document.getElementById("garageLabel").innerHTML=label;
		document.getElementById("MDRSBottomDivBottom").innerHTML="";
		useCarImg = ed.useCarImg;
		useCustomCarImg = ed.useCustomCarImg;
		garageVehicles = ed.vehicles;
		garageVehicles2 = [...new Set(ed.vehicles.map((vehicle) => {return vehicle}))];
		garageVehicles.forEach(function(vehData, index) {
			// Logs
			vehicleLogs[vehData.plate] = [];
			let status;
			let divStyle = "MDRSBDBCarDivInactive";
			let divStyleBorderBottom = "MDRSBDBCarDivBottomBorderInactive";
			status = "Stored";
			divStyle = "MDRSBDBCarDivInactive";
			divStyleBorderBottom = "MDRSBDBCarDivBottomBorderInactive";
			let plateImg = null;
			let plateTextColor = null;
			if (vehData.plateIndex === 0) {
				plateImg = "files/plate1.png";
				plateTextColor = "blue";
			} else if (vehData.plateIndex === 1) {
				plateImg = "files/plate2.png";
				plateTextColor = "yellow;"
			} else if (vehData.plateIndex === 2) {
				plateImg = "files/plate3.png";
				plateTextColor = "yellow";
			} else if (vehData.plateIndex === 3) {
				plateImg = "files/plate4.png";
				plateTextColor = "darkblue";
			} else if (vehData.plateIndex === 4) {
				plateImg = "files/plate1.png";
				plateTextColor = "darkblue";
			} else if (vehData.plateIndex === 5) {
				plateImg = "files/plate6.png";
				plateTextColor = "blue";
			}
			let vehLabel = vehData.vehicleLabel;
			if (vehLabel.length > 15) {
				vehLabel = vehLabel.slice(0, 15) + "...";
			}
			if (useCarImg) {
				checkIfImageExists(`https://docs.fivem.net/vehicles/${vehData.vehicle}.webp`, (exists) => {
					if (exists) {
						var vehiclesHTML = `
						<div class="MDRSBDBCarDiv ${divStyle}" id="MDRSBDBCarDiv-${vehData.plate}" onclick="clFunc('chooseCar', '${vehData.vehicle}', '${vehData.plate}', '${status}', '${vehData.engine}', '${vehData.body}', '${vehData.fuel}', '', '${vehData.index}', '${vehData.type}', '${vehData.depotPrice}')">
							<div id="MDRSBDBCarDivTop">
								<div id="MDRSBDBCarDivTopRectangle"></div><div id="MDRSBDBCarDivTopShared" class="${vehData.shared}"><i style="opacity: 0.42;" class="fas fa-key"></i></div>
								<img src="https://docs.fivem.net/vehicles/${vehData.vehicle}.webp" style="width: 8vw; position: relative; padding-top: 2vw;">
								<div id="MDRSBDBCarDivTopPlate" style="background-image: url(${plateImg}); color: ${plateTextColor};"><h4>${vehData.plate}</h4></div>
							</div>
							<div id="MDRSBDBCarDivBottom"><h4>${vehLabel}</h4><h4>${status}</h4></div>
							<div class="MDRSBDBCarDivBottomBorder ${divStyleBorderBottom}" id="MDRSBDBCarDivBottomBorder-${vehData.plate}"></div>
						</div>`;
						appendHtml(document.getElementById("MDRSBottomDivBottom"), vehiclesHTML);
					} else {
						if (useCustomCarImg) {
							var vehiclesHTML = `
							<div class="MDRSBDBCarDiv ${divStyle}" id="MDRSBDBCarDiv-${vehData.plate}" onclick="clFunc('chooseCar', '${vehData.vehicle}', '${vehData.plate}', '${status}', '${vehData.engine}', '${vehData.body}', '${vehData.fuel}', '', '${vehData.index}', '${vehData.type}', '${vehData.depotPrice}')">
								<div id="MDRSBDBCarDivTop">
									<div id="MDRSBDBCarDivTopRectangle"></div><div id="MDRSBDBCarDivTopShared" class="${vehData.shared}"><i style="opacity: 0.42;" class="fas fa-key"></i></div>
									<img src="cars/${vehData.vehicle}.png" style="width: 8vw; position: relative; padding-top: 2vw;">
									<div id="MDRSBDBCarDivTopPlate" style="background-image: url(${plateImg}); color: ${plateTextColor};"><h4>${vehData.plate}</h4></div>
								</div>
								<div id="MDRSBDBCarDivBottom"><h4>${vehLabel}</h4><h4>${status}</h4></div>
								<div class="MDRSBDBCarDivBottomBorder ${divStyleBorderBottom}" id="MDRSBDBCarDivBottomBorder-${vehData.plate}"></div>
							</div>`;
							appendHtml(document.getElementById("MDRSBottomDivBottom"), vehiclesHTML);
						} else {
							var vehiclesHTML = `
							<div class="MDRSBDBCarDiv ${divStyle}" id="MDRSBDBCarDiv-${vehData.plate}" onclick="clFunc('chooseCar', '${vehData.vehicle}', '${vehData.plate}', '${status}', '${vehData.engine}', '${vehData.body}', '${vehData.fuel}', '', '${vehData.index}', '${vehData.type}', '${vehData.depotPrice}')">
								<div id="MDRSBDBCarDivTop">
									<div id="MDRSBDBCarDivTopRectangle"></div><div id="MDRSBDBCarDivTopShared" class="${vehData.shared}"><i style="opacity: 0.42;" class="fas fa-key"></i></div>
									<img src="files/car.png" style="width: 6vw; position: relative; padding-top: 2vw;">
									<div id="MDRSBDBCarDivTopPlate" style="background-image: url(${plateImg}); color: ${plateTextColor};"><h4>${vehData.plate}</h4></div>
								</div>
								<div id="MDRSBDBCarDivBottom"><h4>${vehLabel}</h4><h4>${status}</h4></div>
								<div class="MDRSBDBCarDivBottomBorder ${divStyleBorderBottom}" id="MDRSBDBCarDivBottomBorder-${vehData.plate}"></div>
							</div>`;
							appendHtml(document.getElementById("MDRSBottomDivBottom"), vehiclesHTML);
						}
					}
				});
			} else {
				var vehiclesHTML = `
				<div class="MDRSBDBCarDiv ${divStyle}" id="MDRSBDBCarDiv-${vehData.plate}" onclick="clFunc('chooseCar', '${vehData.vehicle}', '${vehData.plate}', '${status}', '${vehData.engine}', '${vehData.body}', '${vehData.fuel}', '', '${vehData.index}', '${vehData.type}', '${vehData.depotPrice}')">
					<div id="MDRSBDBCarDivTop">
						<div id="MDRSBDBCarDivTopRectangle"></div><div id="MDRSBDBCarDivTopShared" class="${vehData.shared}"><i style="opacity: 0.42;" class="fas fa-key"></i></div>
						<img src="files/car.png" style="width: 6vw; position: relative; padding-top: 2vw;">
						<div id="MDRSBDBCarDivTopPlate" style="background-image: url(${plateImg}); color: ${plateTextColor};"><h4>${vehData.plate}</h4></div>
					</div>
					<div id="MDRSBDBCarDivBottom"><h4>${vehLabel}</h4><h4>${status}</h4></div>
					<div class="MDRSBDBCarDivBottomBorder ${divStyleBorderBottom}" id="MDRSBDBCarDivBottomBorder-${vehData.plate}"></div>
				</div>`;
				appendHtml(document.getElementById("MDRSBottomDivBottom"), vehiclesHTML);
			}
		});
		document.getElementById("MDRSTDCDiv2").innerHTML=`<div id="MDRSTDCDiv2Inside"><div id="MDRSTDCDiv2I"></div></div><h4 id="MDRSTDCDiv2H41">${ed.limit}</h4>/<h4 id="MDRSTDCDiv2H42">${ed.vehNum}</h4>`;
	}
    document.onkeyup = function(data) {
		if (data.which == 27 && garageOpen) {
			garageOpen = false;
			// document.getElementById("bgEffect").style.display = "none";
			$("#mainDiv").fadeOut(function() {
				document.getElementById("mainDiv").style.display = "none";
			});
			var xhr = new XMLHttpRequest();
			xhr.open("POST", `https://${GetParentResourceName()}/callback`, true);
			xhr.setRequestHeader('Content-Type', 'application/json');
			xhr.send(JSON.stringify({action: "nuiFocus"}));
		}
	}
})

function clFunc(name1, name2, name3, name4, name5, name6, name7, name8, name9, name10, name11) {
	if (name1 === "dropdown") {
		if (dropdownDiv) {
			dropdownDiv = false;
			document.getElementById("MDLSBottomDivParkingLogs").innerHTML = "";
		} else {
			dropdownDiv = true
			document.getElementById("MDLSBottomDivParkingLogs").innerHTML = "";
			vehicleLogs[choosedVehData.plate].forEach(function(logData, index) {
				var logsHTML = `
				<div id="MDLSBDPLBtn2">
					<h4>Log Data</h4>
					<h4>${logData.type} | Garage: ${logData.garage} | Time: ${logData.time}</h4>
				</div>`;
				appendHtml(document.getElementById("MDLSBottomDivParkingLogs"), logsHTML);
			});
		}
	} else if (name1 === "chooseCar") {
		dropdownDiv = false;
		document.getElementById("MDLSBottomDivParkingLogs").innerHTML="";
		// vehicleLogs[name3].forEach(function(logData, index) {
		// 	var logsHTML = `
		// 	<div id="MDLSBDPLBtn2">
		// 		<h4>Log Data</h4>
		// 		<h4>${logData.type} | Garage: ${logData.garage} | Time: ${logData.time}</h4>
		// 	</div>`;
		// 	appendHtml(document.getElementById("MDLSBottomDivParkingLogs"), logsHTML);
		// });
		vehicleStats = {
			fuel: Number(name7),
			engine: Number(name5),
			body: Number(name6),
		};
		choosedVehData = {
			vehicle: name2,
			garage: name8,
			index: name9,
			plate: name3,
			type: name10,
			depotPrice: Number(name11),
			stats: vehicleStats,
		};
		document.getElementById("currentVehiclePlate").innerHTML=name3;
		document.getElementById("vehicleStatusH4").innerHTML=`${name4} | Engine: ${Number(name5) / 10}% | Body: ${Number(name6) / 10}%`;
		$("#MDLeftSide").css({left: "-7%", position:'relative', opacity: 1}).animate({left: "0"}, 600, function() {});
		if (choosedCar) {
			// Main Div
			document.getElementById("MDRSBDBCarDiv-" + choosedCar).classList.remove("MDRSBDBCarDivActive");
			document.getElementById("MDRSBDBCarDiv-" + choosedCar).classList.add("MDRSBDBCarDivInactive");
			if (name4 === "Stored") {
				document.getElementById("MDLSBDTakeOutBtn").classList.remove("MDLSBDTakeOutBtnInactive");
				document.getElementById("MDLSBDTakeOutBtn").classList.add("MDLSBDTakeOutBtnActive");
				document.getElementById("MDRSBDBCarDiv-" + name3).classList.remove("MDRSBDBCarDivInactive");
				document.getElementById("MDRSBDBCarDiv-" + name3).classList.add("MDRSBDBCarDivActive");
				// Bottom Border
				document.getElementById("MDRSBDBCarDivBottomBorder-" + choosedCar).classList.remove("MDRSBDBCarDivBottomBorderActive");
				document.getElementById("MDRSBDBCarDivBottomBorder-" + choosedCar).classList.add("MDRSBDBCarDivBottomBorderInactive");
				document.getElementById("MDRSBDBCarDivBottomBorder-" + name3).classList.remove("MDRSBDBCarDivBottomBorderInactive");
				document.getElementById("MDRSBDBCarDivBottomBorder-" + name3).classList.add("MDRSBDBCarDivBottomBorderActive");
				// Button
				document.getElementById("MDLSBDTakeOutBtn").innerHTML="Take Out Vehicle";
				document.getElementById("MDLSBDTakeOutBtn").setAttribute('onclick', 'clFunc("takeOutVehicle")');
			} else {
				document.getElementById("MDLSBDTakeOutBtn").classList.add("MDLSBDTakeOutBtnInactive");
				document.getElementById("MDLSBDTakeOutBtn").classList.remove("MDLSBDTakeOutBtnActive");
				// Button
				document.getElementById("MDLSBDTakeOutBtn").innerHTML="Depot Vehicle";
				document.getElementById("MDLSBDTakeOutBtn").setAttribute('onclick', 'clFunc("takeDepotVehicle")');
			}
		} else {
			if (name4 === "Stored") {
				document.getElementById("MDLSBDTakeOutBtn").classList.remove("MDLSBDTakeOutBtnInactive");
				document.getElementById("MDLSBDTakeOutBtn").classList.add("MDLSBDTakeOutBtnActive");
				// Main Div
				document.getElementById("MDRSBDBCarDiv-" + name3).classList.remove("MDRSBDBCarDivInactive");
				document.getElementById("MDRSBDBCarDiv-" + name3).classList.add("MDRSBDBCarDivActive");
				// Bottom Border
				document.getElementById("MDRSBDBCarDivBottomBorder-" + name3).classList.remove("MDRSBDBCarDivBottomBorderInactive");
				document.getElementById("MDRSBDBCarDivBottomBorder-" + name3).classList.add("MDRSBDBCarDivBottomBorderActive");
				// Button
				document.getElementById("MDLSBDTakeOutBtn").innerHTML="Take Out Vehicle";
				document.getElementById("MDLSBDTakeOutBtn").setAttribute('onclick', 'clFunc("takeOutVehicle")');
			} else {
				document.getElementById("MDLSBDTakeOutBtn").classList.add("MDLSBDTakeOutBtnInactive");
				document.getElementById("MDLSBDTakeOutBtn").classList.remove("MDLSBDTakeOutBtnActive");
				// Button
				document.getElementById("MDLSBDTakeOutBtn").innerHTML="Depot Vehicle";
				document.getElementById("MDLSBDTakeOutBtn").setAttribute('onclick', 'clFunc("takeDepotVehicle")');
			}
		}
		choosedCar = name3;
	} else if (name1 === "closeLeftSide") {
		$("#MDLeftSide").css({left: "0%", position:'relative', opacity: 0}).animate({left: "-7%"}, 600, function() {});
		document.getElementById("MDRSBDBCarDiv-" + choosedCar).classList.remove("MDRSBDBCarDivActive");
		document.getElementById("MDRSBDBCarDiv-" + choosedCar).classList.add("MDRSBDBCarDivInactive");
	} else if (name1 === "showVehicles") {
		// Button All
		document.getElementById("MDRSBottomDivTopButtonAll").classList.remove("MDRSBottomDivTopButtonActive");
		document.getElementById("MDRSBottomDivTopButtonAll").classList.add("MDRSBottomDivTopButtonInactive");
		// Button Personal
		document.getElementById("MDRSBottomDivTopButtonPersonal").classList.remove("MDRSBottomDivTopButtonActive");
		document.getElementById("MDRSBottomDivTopButtonPersonal").classList.add("MDRSBottomDivTopButtonInactive");
		// Button Job
		document.getElementById("MDRSBottomDivTopButtonJob").classList.remove("MDRSBottomDivTopButtonActive");
		document.getElementById("MDRSBottomDivTopButtonJob").classList.add("MDRSBottomDivTopButtonInactive");
		document.getElementById("MDRSBottomDivTopButton" + name2).classList.remove("MDRSBottomDivTopButtonInactive");
		document.getElementById("MDRSBottomDivTopButton" + name2).classList.add("MDRSBottomDivTopButtonActive");
		// Functions
		document.getElementById("MDLeftSide").style.opacity = "0";
		document.getElementById("MDRSBottomDivBottom").innerHTML="";
		let parkedVehNum = 0;
		let totalVehNum = 0;
		choosedCar = null;
		if (name2 === "All") {
			garageVehicles.forEach(function(vehData, index) {
				totalVehNum = totalVehNum + 1;
				let status;
				let isDepotPrice2 = false;
				let divStyle = "MDRSBDBCarDivInactive";
				let divStyleBorderBottom = "MDRSBDBCarDivBottomBorderInactive";
				if (vehData.state === 0) {
					if (vehData.depotPrice && vehData.depotPrice > 0) {
						isDepotPrice2 = true;
						divStyle = "MDRSBDBCarDivDepot";
						if (vehData.type === "public") {
							status = "Depot";
							divStyleBorderBottom = "MDRSBDBCarDivBottomBorderDepot";
						} else if (vehData.type === "depot") {
							status = "$" + vehData.depotPrice.toFixed(0);
							divStyleBorderBottom = "MDRSBDBCarDivBottomBorderDepot";
						} else {
							status = "Out";
							divStyleBorderBottom = "MDRSBDBCarDivBottomBorderOut";
						}
					} else {
						divStyle = "MDRSBDBCarDivOut";
						divStyleBorderBottom = "MDRSBDBCarDivBottomBorderOut";
						status = "Out";
					}
				} else if (vehData.state === 1) {
					if (vehData.depotPrice && vehData.depotPrice > 0) {
						isDepotPrice2 = true;
						if (vehData.type === "depot") {
							status = "$" + vehData.depotPrice.toFixed(0);
							divStyle = "MDRSBDBCarDivDepot";
							divStyleBorderBottom = "MDRSBDBCarDivBottomBorderDepot";
						} else if (vehData.type === "public") {
							status = "Depot";
							divStyle = "MDRSBDBCarDivDepot";
							divStyleBorderBottom = "MDRSBDBCarDivBottomBorderDepot";
						} else {
							status = "Stored";
							divStyle = "MDRSBDBCarDivInactive";
							divStyleBorderBottom = "MDRSBDBCarDivBottomBorderInactive";
							parkedVehNum = parkedVehNum + 1;
						}
					} else {
						status = "Stored";
						divStyle = "MDRSBDBCarDivInactive";
						divStyleBorderBottom = "MDRSBDBCarDivBottomBorderInactive";
						parkedVehNum = parkedVehNum + 1;
					}
				} else if (vehData.state === 2) {
					status = "Impound";
				}
				let plateImg = null;
				let plateTextColor = null;
				if (vehData.plateIndex === 0) {
					plateImg = "files/plate1.png";
					plateTextColor = "blue";
				} else if (vehData.plateIndex === 1) {
					plateImg = "files/plate2.png";
					plateTextColor = "yellow;"
				} else if (vehData.plateIndex === 2) {
					plateImg = "files/plate3.png";
					plateTextColor = "yellow";
				} else if (vehData.plateIndex === 3) {
					plateImg = "files/plate4.png";
					plateTextColor = "darkblue";
				} else if (vehData.plateIndex === 4) {
					plateImg = "files/plate1.png";
					plateTextColor = "darkblue";
				} else if (vehData.plateIndex === 5) {
					plateImg = "files/plate6.png";
					plateTextColor = "blue";
				}
				let vehLabel = vehData.vehicleLabel;
				if (vehLabel.length > 15) {
					vehLabel = vehLabel.slice(0, 15) + "...";
				}
				if (useCarImg) {
					checkIfImageExists(`https://docs.fivem.net/vehicles/${vehData.vehicle}.webp`, (exists) => {
						if (exists) {
							var vehiclesHTML = `
							<div class="MDRSBDBCarDiv ${divStyle}" id="MDRSBDBCarDiv-${vehData.plate}" onclick="clFunc('chooseCar', '${vehData.vehicle}', '${vehData.plate}', '${status}', '${vehData.engine}', '${vehData.body}', '${vehData.fuel}', '', '${vehData.index}', '${vehData.type}', '${vehData.depotPrice}')">
								<div id="MDRSBDBCarDivTop">
									<div id="MDRSBDBCarDivTopRectangle"></div><div id="MDRSBDBCarDivTopShared" class="${vehData.shared}"><i style="opacity: 0.42;" class="fas fa-key"></i></div>
									<img src="https://docs.fivem.net/vehicles/${vehData.vehicle}.webp" style="width: 8vw; position: relative; padding-top: 2vw;">
									<div id="MDRSBDBCarDivTopPlate" style="background-image: url(${plateImg}); color: ${plateTextColor};"><h4>${vehData.plate}</h4></div>
								</div>
								<div id="MDRSBDBCarDivBottom"><h4>${vehLabel}</h4><h4>${status}</h4></div>
								<div class="MDRSBDBCarDivBottomBorder ${divStyleBorderBottom}" id="MDRSBDBCarDivBottomBorder-${vehData.plate}"></div>
							</div>`;
							appendHtml(document.getElementById("MDRSBottomDivBottom"), vehiclesHTML);
						} else {
							if (useCustomCarImg) {
								var vehiclesHTML = `
								<div class="MDRSBDBCarDiv ${divStyle}" id="MDRSBDBCarDiv-${vehData.plate}" onclick="clFunc('chooseCar', '${vehData.vehicle}', '${vehData.plate}', '${status}', '${vehData.engine}', '${vehData.body}', '${vehData.fuel}', '', '${vehData.index}', '${vehData.type}', '${vehData.depotPrice}')">
									<div id="MDRSBDBCarDivTop">
										<div id="MDRSBDBCarDivTopRectangle"></div><div id="MDRSBDBCarDivTopShared" class="${vehData.shared}"><i style="opacity: 0.42;" class="fas fa-key"></i></div>
										<img src="cars/${vehData.vehicle}.png" style="width: 8vw; position: relative; padding-top: 2vw;">
										<div id="MDRSBDBCarDivTopPlate" style="background-image: url(${plateImg}); color: ${plateTextColor};"><h4>${vehData.plate}</h4></div>
									</div>
									<div id="MDRSBDBCarDivBottom"><h4>${vehLabel}</h4><h4>${status}</h4></div>
									<div class="MDRSBDBCarDivBottomBorder ${divStyleBorderBottom}" id="MDRSBDBCarDivBottomBorder-${vehData.plate}"></div>
								</div>`;
								appendHtml(document.getElementById("MDRSBottomDivBottom"), vehiclesHTML);
							} else {
								var vehiclesHTML = `
								<div class="MDRSBDBCarDiv ${divStyle}" id="MDRSBDBCarDiv-${vehData.plate}" onclick="clFunc('chooseCar', '${vehData.vehicle}', '${vehData.plate}', '${status}', '${vehData.engine}', '${vehData.body}', '${vehData.fuel}', '', '${vehData.index}', '${vehData.type}', '${vehData.depotPrice}')">
									<div id="MDRSBDBCarDivTop">
										<div id="MDRSBDBCarDivTopRectangle"></div><div id="MDRSBDBCarDivTopShared" class="${vehData.shared}"><i style="opacity: 0.42;" class="fas fa-key"></i></div>
										<img src="files/car.png" style="width: 6vw; position: relative; padding-top: 2vw;">
										<div id="MDRSBDBCarDivTopPlate" style="background-image: url(${plateImg}); color: ${plateTextColor};"><h4>${vehData.plate}</h4></div>
									</div>
									<div id="MDRSBDBCarDivBottom"><h4>${vehLabel}</h4><h4>${status}</h4></div>
									<div class="MDRSBDBCarDivBottomBorder ${divStyleBorderBottom}" id="MDRSBDBCarDivBottomBorder-${vehData.plate}"></div>
								</div>`;
								appendHtml(document.getElementById("MDRSBottomDivBottom"), vehiclesHTML);
							}
						}
					});
				} else {
					var vehiclesHTML = `
					<div class="MDRSBDBCarDiv ${divStyle}" id="MDRSBDBCarDiv-${vehData.plate}" onclick="clFunc('chooseCar', '${vehData.vehicle}', '${vehData.plate}', '${status}', '${vehData.engine}', '${vehData.body}', '${vehData.fuel}', '', '${vehData.index}', '${vehData.type}', '${vehData.depotPrice}')">
						<div id="MDRSBDBCarDivTop">
							<div id="MDRSBDBCarDivTopRectangle"></div><div id="MDRSBDBCarDivTopShared" class="${vehData.shared}"><i style="opacity: 0.42;" class="fas fa-key"></i></div>
							<img src="files/car.png" style="width: 6vw; position: relative; padding-top: 2vw;">
							<div id="MDRSBDBCarDivTopPlate" style="background-image: url(${plateImg}); color: ${plateTextColor};"><h4>${vehData.plate}</h4></div>
						</div>
						<div id="MDRSBDBCarDivBottom"><h4>${vehLabel}</h4><h4>${status}</h4></div>
						<div class="MDRSBDBCarDivBottomBorder ${divStyleBorderBottom}" id="MDRSBDBCarDivBottomBorder-${vehData.plate}"></div>
					</div>`;
					appendHtml(document.getElementById("MDRSBottomDivBottom"), vehiclesHTML);
				}
			});
			document.getElementById("MDRSTDCDiv2").innerHTML=`<div id="MDRSTDCDiv2Inside"><div id="MDRSTDCDiv2I"></div></div><h4 id="MDRSTDCDiv2H41">${parkedVehNum}</h4>/<h4 id="MDRSTDCDiv2H42">${totalVehNum}</h4>`;
		} else if (name2 === "Personal") {
			garageVehicles.forEach(function(vehData, index) {
				if (vehData.vehClass === 0 || vehData.vehClass === 1 || vehData.vehClass === 2 || vehData.vehClass === 3 || vehData.vehClass === 4 || vehData.vehClass === 5 || vehData.vehClass === 6 || vehData.vehClass === 7 || vehData.vehClass === 8 || vehData.vehClass === 9 || vehData.vehClass === 11 || vehData.vehClass === 12 || vehData.vehClass === 13) {
					totalVehNum = totalVehNum + 1;
					let status;
					let isDepotPrice3 = false;
					let divStyle = "MDRSBDBCarDivInactive";
					let divStyleBorderBottom = "MDRSBDBCarDivBottomBorderInactive";
					if (vehData.state === 0) {
						if (vehData.depotPrice && vehData.depotPrice > 0) {
							isDepotPrice3 = true;
							divStyle = "MDRSBDBCarDivDepot";
							if (vehData.type === "public") {
								status = "Depot";
								divStyleBorderBottom = "MDRSBDBCarDivBottomBorderDepot";
							} else if (vehData.type === "depot") {
								status = "$" + vehData.depotPrice.toFixed(0);
								divStyleBorderBottom = "MDRSBDBCarDivBottomBorderDepot";
							} else {
								status = "Out";
								divStyleBorderBottom = "MDRSBDBCarDivBottomBorderOut";
							}
						} else {
							divStyle = "MDRSBDBCarDivOut";
							divStyleBorderBottom = "MDRSBDBCarDivBottomBorderOut";
							status = "Out";
						}
					} else if (vehData.state === 1) {
						if (vehData.depotPrice && vehData.depotPrice > 0) {
							isDepotPrice3 = true;
							if (vehData.type === "depot") {
								status = "$" + vehData.depotPrice.toFixed(0);
								divStyle = "MDRSBDBCarDivDepot";
								divStyleBorderBottom = "MDRSBDBCarDivBottomBorderDepot";
							} else if (vehData.type === "public") {
								status = "Depot";
								divStyle = "MDRSBDBCarDivDepot";
								divStyleBorderBottom = "MDRSBDBCarDivBottomBorderDepot";
							} else {
								status = "Stored";
								divStyle = "MDRSBDBCarDivInactive";
								divStyleBorderBottom = "MDRSBDBCarDivBottomBorderInactive";
								parkedVehNum = parkedVehNum + 1;
							}
						} else {
							status = "Stored";
							divStyle = "MDRSBDBCarDivInactive";
							divStyleBorderBottom = "MDRSBDBCarDivBottomBorderInactive";
							parkedVehNum = parkedVehNum + 1;
						}
					} else if (vehData.state === 2) {
						status = "Impound";
					}
					let plateImg = null;
					let plateTextColor = null;
					if (vehData.plateIndex === 0) {
						plateImg = "files/plate1.png";
						plateTextColor = "blue";
					} else if (vehData.plateIndex === 1) {
						plateImg = "files/plate2.png";
						plateTextColor = "yellow;"
					} else if (vehData.plateIndex === 2) {
						plateImg = "files/plate3.png";
						plateTextColor = "yellow";
					} else if (vehData.plateIndex === 3) {
						plateImg = "files/plate4.png";
						plateTextColor = "darkblue";
					} else if (vehData.plateIndex === 4) {
						plateImg = "files/plate1.png";
						plateTextColor = "darkblue";
					} else if (vehData.plateIndex === 5) {
						plateImg = "files/plate6.png";
						plateTextColor = "blue";
					}
					let vehLabel = vehData.vehicleLabel;
					if (vehLabel.length > 15) {
						vehLabel = vehLabel.slice(0, 15) + "...";
					}
					if (useCarImg) {
						checkIfImageExists(`https://docs.fivem.net/vehicles/${vehData.vehicle}.webp`, (exists) => {
							if (exists) {
								var vehiclesHTML = `
								<div class="MDRSBDBCarDiv ${divStyle}" id="MDRSBDBCarDiv-${vehData.plate}" onclick="clFunc('chooseCar', '${vehData.vehicle}', '${vehData.plate}', '${status}', '${vehData.engine}', '${vehData.body}', '${vehData.fuel}', '', '${vehData.index}', '${vehData.type}', '${vehData.depotPrice}')">
									<div id="MDRSBDBCarDivTop">
										<div id="MDRSBDBCarDivTopRectangle"></div><div id="MDRSBDBCarDivTopShared" class="${vehData.shared}"><i style="opacity: 0.42;" class="fas fa-key"></i></div>
										<img src="https://docs.fivem.net/vehicles/${vehData.vehicle}.webp" style="width: 8vw; position: relative; padding-top: 2vw;">
										<div id="MDRSBDBCarDivTopPlate" style="background-image: url(${plateImg}); color: ${plateTextColor};"><h4>${vehData.plate}</h4></div>
									</div>
									<div id="MDRSBDBCarDivBottom"><h4>${vehLabel}</h4><h4>${status}</h4></div>
									<div class="MDRSBDBCarDivBottomBorder ${divStyleBorderBottom}" id="MDRSBDBCarDivBottomBorder-${vehData.plate}"></div>
								</div>`;
								appendHtml(document.getElementById("MDRSBottomDivBottom"), vehiclesHTML);
							} else {
								if (useCustomCarImg) {
									var vehiclesHTML = `
									<div class="MDRSBDBCarDiv ${divStyle}" id="MDRSBDBCarDiv-${vehData.plate}" onclick="clFunc('chooseCar', '${vehData.vehicle}', '${vehData.plate}', '${status}', '${vehData.engine}', '${vehData.body}', '${vehData.fuel}', '', '${vehData.index}', '${vehData.type}', '${vehData.depotPrice}')">
										<div id="MDRSBDBCarDivTop">
											<div id="MDRSBDBCarDivTopRectangle"></div><div id="MDRSBDBCarDivTopShared" class="${vehData.shared}"><i style="opacity: 0.42;" class="fas fa-key"></i></div>
											<img src="cars/${vehData.vehicle}.png" style="width: 8vw; position: relative; padding-top: 2vw;">
											<div id="MDRSBDBCarDivTopPlate" style="background-image: url(${plateImg}); color: ${plateTextColor};"><h4>${vehData.plate}</h4></div>
										</div>
										<div id="MDRSBDBCarDivBottom"><h4>${vehLabel}</h4><h4>${status}</h4></div>
										<div class="MDRSBDBCarDivBottomBorder ${divStyleBorderBottom}" id="MDRSBDBCarDivBottomBorder-${vehData.plate}"></div>
									</div>`;
									appendHtml(document.getElementById("MDRSBottomDivBottom"), vehiclesHTML);
								} else {
									var vehiclesHTML = `
									<div class="MDRSBDBCarDiv ${divStyle}" id="MDRSBDBCarDiv-${vehData.plate}" onclick="clFunc('chooseCar', '${vehData.vehicle}', '${vehData.plate}', '${status}', '${vehData.engine}', '${vehData.body}', '${vehData.fuel}', '', '${vehData.index}', '${vehData.type}', '${vehData.depotPrice}')">
										<div id="MDRSBDBCarDivTop">
											<div id="MDRSBDBCarDivTopRectangle"></div><div id="MDRSBDBCarDivTopShared" class="${vehData.shared}"><i style="opacity: 0.42;" class="fas fa-key"></i></div>
											<img src="files/car.png" style="width: 6vw; position: relative; padding-top: 2vw;">
											<div id="MDRSBDBCarDivTopPlate" style="background-image: url(${plateImg}); color: ${plateTextColor};"><h4>${vehData.plate}</h4></div>
										</div>
										<div id="MDRSBDBCarDivBottom"><h4>${vehLabel}</h4><h4>${status}</h4></div>
										<div class="MDRSBDBCarDivBottomBorder ${divStyleBorderBottom}" id="MDRSBDBCarDivBottomBorder-${vehData.plate}"></div>
									</div>`;
									appendHtml(document.getElementById("MDRSBottomDivBottom"), vehiclesHTML);
								}
							}
						});
					} else {
						var vehiclesHTML = `
						<div class="MDRSBDBCarDiv ${divStyle}" id="MDRSBDBCarDiv-${vehData.plate}" onclick="clFunc('chooseCar', '${vehData.vehicle}', '${vehData.plate}', '${status}', '${vehData.engine}', '${vehData.body}', '${vehData.fuel}', '', '${vehData.index}', '${vehData.type}', '${vehData.depotPrice}')">
							<div id="MDRSBDBCarDivTop">
								<div id="MDRSBDBCarDivTopRectangle"></div><div id="MDRSBDBCarDivTopShared" class="${vehData.shared}"><i style="opacity: 0.42;" class="fas fa-key"></i></div>
								<img src="files/car.png" style="width: 6vw; position: relative; padding-top: 2vw;">
								<div id="MDRSBDBCarDivTopPlate" style="background-image: url(${plateImg}); color: ${plateTextColor};"><h4>${vehData.plate}</h4></div>
							</div>
							<div id="MDRSBDBCarDivBottom"><h4>${vehLabel}</h4><h4>${status}</h4></div>
							<div class="MDRSBDBCarDivBottomBorder ${divStyleBorderBottom}" id="MDRSBDBCarDivBottomBorder-${vehData.plate}"></div>
						</div>`;
						appendHtml(document.getElementById("MDRSBottomDivBottom"), vehiclesHTML);
					}
				}
			});
			document.getElementById("MDRSTDCDiv2").innerHTML=`<div id="MDRSTDCDiv2Inside"><div id="MDRSTDCDiv2I"></div></div><h4 id="MDRSTDCDiv2H41">${parkedVehNum}</h4>/<h4 id="MDRSTDCDiv2H42">${totalVehNum}</h4>`;
		} else if (name2 === "Job") {
			garageVehicles.forEach(function(vehData, index) {
				if (vehData.vehClass === 17 || vehData.vehClass === 18 || vehData.vehClass === 19 || vehData.vehClass === 20 || vehData.vehClass === 10) {
					totalVehNum = totalVehNum + 1;
					let status;
					let isDepotPrice4 = false;
					let divStyle = "MDRSBDBCarDivInactive";
					let divStyleBorderBottom = "MDRSBDBCarDivBottomBorderInactive";
					if (vehData.state === 0) {
						if (vehData.depotPrice && vehData.depotPrice > 0) {
							isDepotPrice4 = true;
							divStyle = "MDRSBDBCarDivDepot";
							if (vehData.type === "public") {
								status = "Depot";
								divStyleBorderBottom = "MDRSBDBCarDivBottomBorderDepot";
							} else if (vehData.type === "depot") {
								status = "$" + vehData.depotPrice.toFixed(0);
								divStyleBorderBottom = "MDRSBDBCarDivBottomBorderDepot";
							} else {
								status = "Out";
								divStyleBorderBottom = "MDRSBDBCarDivBottomBorderOut";
							}
						} else {
							divStyle = "MDRSBDBCarDivOut";
							divStyleBorderBottom = "MDRSBDBCarDivBottomBorderOut";
							status = "Out";
						}
					} else if (vehData.state === 1) {
						if (vehData.depotPrice && vehData.depotPrice > 0) {
							isDepotPrice4 = true;
							if (vehData.type === "depot") {
								status = "$" + vehData.depotPrice.toFixed(0);
								divStyle = "MDRSBDBCarDivDepot";
								divStyleBorderBottom = "MDRSBDBCarDivBottomBorderDepot";
							} else if (vehData.type === "public") {
								status = "Depot";
								divStyle = "MDRSBDBCarDivDepot";
								divStyleBorderBottom = "MDRSBDBCarDivBottomBorderDepot";
							} else {
								status = "Stored";
								divStyle = "MDRSBDBCarDivInactive";
								divStyleBorderBottom = "MDRSBDBCarDivBottomBorderInactive";
								parkedVehNum = parkedVehNum + 1;
							}
						} else {
							status = "Stored";
							divStyle = "MDRSBDBCarDivInactive";
							divStyleBorderBottom = "MDRSBDBCarDivBottomBorderInactive";
							parkedVehNum = parkedVehNum + 1;
						}
					} else if (vehData.state === 2) {
						status = "Impound";
					}
					let plateImg = null;
					let plateTextColor = null;
					if (vehData.plateIndex === 0) {
						plateImg = "files/plate1.png";
						plateTextColor = "blue";
					} else if (vehData.plateIndex === 1) {
						plateImg = "files/plate2.png";
						plateTextColor = "yellow;"
					} else if (vehData.plateIndex === 2) {
						plateImg = "files/plate3.png";
						plateTextColor = "yellow";
					} else if (vehData.plateIndex === 3) {
						plateImg = "files/plate4.png";
						plateTextColor = "darkblue";
					} else if (vehData.plateIndex === 4) {
						plateImg = "files/plate1.png";
						plateTextColor = "darkblue";
					} else if (vehData.plateIndex === 5) {
						plateImg = "files/plate6.png";
						plateTextColor = "blue";
					}
					let vehLabel = vehData.vehicleLabel;
					if (vehLabel.length > 15) {
						vehLabel = vehLabel.slice(0, 15) + "...";
					}
					if (useCarImg) {
						checkIfImageExists(`https://docs.fivem.net/vehicles/${vehData.vehicle}.webp`, (exists) => {
							if (exists) {
								var vehiclesHTML = `
								<div class="MDRSBDBCarDiv ${divStyle}" id="MDRSBDBCarDiv-${vehData.plate}" onclick="clFunc('chooseCar', '${vehData.vehicle}', '${vehData.plate}', '${status}', '${vehData.engine}', '${vehData.body}', '${vehData.fuel}', '', '${vehData.index}', '${vehData.type}', '${vehData.depotPrice}')">
									<div id="MDRSBDBCarDivTop">
										<div id="MDRSBDBCarDivTopRectangle"></div><div id="MDRSBDBCarDivTopShared" class="${vehData.shared}"><i style="opacity: 0.42;" class="fas fa-key"></i></div>
										<img src="https://docs.fivem.net/vehicles/${vehData.vehicle}.webp" style="width: 8vw; position: relative; padding-top: 2vw;">
										<div id="MDRSBDBCarDivTopPlate" style="background-image: url(${plateImg}); color: ${plateTextColor};"><h4>${vehData.plate}</h4></div>
									</div>
									<div id="MDRSBDBCarDivBottom"><h4>${vehLabel}</h4><h4>${status}</h4></div>
									<div class="MDRSBDBCarDivBottomBorder ${divStyleBorderBottom}" id="MDRSBDBCarDivBottomBorder-${vehData.plate}"></div>
								</div>`;
								appendHtml(document.getElementById("MDRSBottomDivBottom"), vehiclesHTML);
							} else {
								if (useCustomCarImg) {
									var vehiclesHTML = `
									<div class="MDRSBDBCarDiv ${divStyle}" id="MDRSBDBCarDiv-${vehData.plate}" onclick="clFunc('chooseCar', '${vehData.vehicle}', '${vehData.plate}', '${status}', '${vehData.engine}', '${vehData.body}', '${vehData.fuel}', '', '${vehData.index}', '${vehData.type}', '${vehData.depotPrice}')">
										<div id="MDRSBDBCarDivTop">
											<div id="MDRSBDBCarDivTopRectangle"></div><div id="MDRSBDBCarDivTopShared" class="${vehData.shared}"><i style="opacity: 0.42;" class="fas fa-key"></i></div>
											<img src="cars/${vehData.vehicle}.png" style="width: 8vw; position: relative; padding-top: 2vw;">
											<div id="MDRSBDBCarDivTopPlate" style="background-image: url(${plateImg}); color: ${plateTextColor};"><h4>${vehData.plate}</h4></div>
										</div>
										<div id="MDRSBDBCarDivBottom"><h4>${vehLabel}</h4><h4>${status}</h4></div>
										<div class="MDRSBDBCarDivBottomBorder ${divStyleBorderBottom}" id="MDRSBDBCarDivBottomBorder-${vehData.plate}"></div>
									</div>`;
									appendHtml(document.getElementById("MDRSBottomDivBottom"), vehiclesHTML);
								} else {
									var vehiclesHTML = `
									<div class="MDRSBDBCarDiv ${divStyle}" id="MDRSBDBCarDiv-${vehData.plate}" onclick="clFunc('chooseCar', '${vehData.vehicle}', '${vehData.plate}', '${status}', '${vehData.engine}', '${vehData.body}', '${vehData.fuel}', '', '${vehData.index}', '${vehData.type}', '${vehData.depotPrice}')">
										<div id="MDRSBDBCarDivTop">
											<div id="MDRSBDBCarDivTopRectangle"></div><div id="MDRSBDBCarDivTopShared" class="${vehData.shared}"><i style="opacity: 0.42;" class="fas fa-key"></i></div>
											<img src="files/car.png" style="width: 6vw; position: relative; padding-top: 2vw;">
											<div id="MDRSBDBCarDivTopPlate" style="background-image: url(${plateImg}); color: ${plateTextColor};"><h4>${vehData.plate}</h4></div>
										</div>
										<div id="MDRSBDBCarDivBottom"><h4>${vehLabel}</h4><h4>${status}</h4></div>
										<div class="MDRSBDBCarDivBottomBorder ${divStyleBorderBottom}" id="MDRSBDBCarDivBottomBorder-${vehData.plate}"></div>
									</div>`;
									appendHtml(document.getElementById("MDRSBottomDivBottom"), vehiclesHTML);
								}
							}
						});
					} else {
						var vehiclesHTML = `
						<div class="MDRSBDBCarDiv ${divStyle}" id="MDRSBDBCarDiv-${vehData.plate}" onclick="clFunc('chooseCar', '${vehData.vehicle}', '${vehData.plate}', '${status}', '${vehData.engine}', '${vehData.body}', '${vehData.fuel}', '', '${vehData.index}', '${vehData.type}', '${vehData.depotPrice}')">
							<div id="MDRSBDBCarDivTop">
								<div id="MDRSBDBCarDivTopRectangle"></div><div id="MDRSBDBCarDivTopShared" class="${vehData.shared}"><i style="opacity: 0.42;" class="fas fa-key"></i></div>
								<img src="files/car.png" style="width: 6vw; position: relative; padding-top: 2vw;">
								<div id="MDRSBDBCarDivTopPlate" style="background-image: url(${plateImg}); color: ${plateTextColor};"><h4>${vehData.plate}</h4></div>
							</div>
							<div id="MDRSBDBCarDivBottom"><h4>${vehLabel}</h4><h4>${status}</h4></div>
							<div class="MDRSBDBCarDivBottomBorder ${divStyleBorderBottom}" id="MDRSBDBCarDivBottomBorder-${vehData.plate}"></div>
						</div>`;
						appendHtml(document.getElementById("MDRSBottomDivBottom"), vehiclesHTML);
					}
				}
			});
			document.getElementById("MDRSTDCDiv2").innerHTML=`<div id="MDRSTDCDiv2Inside"><div id="MDRSTDCDiv2I"></div></div><h4 id="MDRSTDCDiv2H41">${parkedVehNum}</h4>/<h4 id="MDRSTDCDiv2H42">${totalVehNum}</h4>`;
		}
	} else if (name1 === "takeOutVehicle") {
		if (currentGarageType === "public" || currentGarageType === "gang" || currentGarageType === "job" || currentGarageType === "house") {
			var xhr = new XMLHttpRequest();
			xhr.open("POST", `https://${GetParentResourceName()}/callback`, true);
			xhr.setRequestHeader('Content-Type', 'application/json');
			xhr.send(JSON.stringify({action: "takeOutVehicle", data: choosedVehData}));
			garageOpen = false;
			// document.getElementById("bgEffect").style.display = "none";
			$("#mainDiv").fadeOut(function() {
				document.getElementById("mainDiv").style.display = "none";
			});
			var xhr = new XMLHttpRequest();
			xhr.open("POST", `https://${GetParentResourceName()}/callback`, true);
			xhr.setRequestHeader('Content-Type', 'application/json');
			xhr.send(JSON.stringify({action: "nuiFocus"}));
		}
	} else if (name1 === "takeDepotVehicle") {
		if (currentGarageType === "depot") {
			var xhr = new XMLHttpRequest();
			xhr.open("POST", `https://${GetParentResourceName()}/callback`, true);
			xhr.setRequestHeader('Content-Type', 'application/json');
			xhr.send(JSON.stringify({action: "takeOutDepo", data: choosedVehData}));
			garageOpen = false;
			// document.getElementById("bgEffect").style.display = "none";
			$("#mainDiv").fadeOut(function() {
				document.getElementById("mainDiv").style.display = "none";
			});
			var xhr = new XMLHttpRequest();
			xhr.open("POST", `https://${GetParentResourceName()}/callback`, true);
			xhr.setRequestHeader('Content-Type', 'application/json');
			xhr.send(JSON.stringify({action: "nuiFocus"}));
		}
	}
}

function appendHtml(el, str) {
	var div = document.createElement('div');
	div.innerHTML = str;
	while (div.children.length > 0) {
		el.appendChild(div.children[0]);
	}
}

document.getElementById("MDRSBottomDivTopInput").addEventListener('input', (e) => {
	// const searchData = e.target.value.toLowerCase();
	// const filterData = garageVehicles2.filter((vehicle) => {
	// 	return (vehicle.vehicleLabel.toLocaleLowerCase().includes(searchData))
	// });
	// displaySearchedVehicle(filterData);
	const userInput = e.target.value;
    if (userInput.length !== 0) {
		displaySearchedVehicle(findCarByPartialLabel(garageVehicles2, userInput))
    } else {
        displaySearchedVehicle(garageVehicles2);
    }
});

const displaySearchedVehicle = (vehicles) => {
	totalVehNum = 0;
	document.getElementById("MDRSBottomDivBottom").innerHTML="";
	vehicles.forEach(function(vehData, index) {
		totalVehNum = totalVehNum + 1;
		let status;
		let isDepotPrice5 = false;
		let divStyle = "MDRSBDBCarDivInactive";
		let divStyleBorderBottom = "MDRSBDBCarDivBottomBorderInactive";
		if (vehData.state === 0) {
			if (vehData.depotPrice && vehData.depotPrice > 0) {
				isDepotPrice5 = true;
				divStyle = "MDRSBDBCarDivDepot";
				if (vehData.type === "public") {
					status = "Depot";
					divStyleBorderBottom = "MDRSBDBCarDivBottomBorderDepot";
				} else if (vehData.type === "depot") {
					status = "$" + depotPrice.toFixed(0);
					divStyleBorderBottom = "MDRSBDBCarDivBottomBorderDepot";
				} else {
					status = "Out";
					divStyleBorderBottom = "MDRSBDBCarDivBottomBorderOut";
				}
			} else {
				divStyle = "MDRSBDBCarDivOut";
				divStyleBorderBottom = "MDRSBDBCarDivBottomBorderOut";
				status = "Out";
			}
		} else if (vehData.state === 1) {
			if (vehData.depotPrice && vehData.depotPrice > 0) {
				isDepotPrice5 = true;
				if (vehData.type === "depot") {
					status = "$" + depotPrice.toFixed(0);
					divStyle = "MDRSBDBCarDivDepot";
					divStyleBorderBottom = "MDRSBDBCarDivBottomBorderDepot";
				} else if (vehData.type === "public") {
					status = "Depot";
					divStyle = "MDRSBDBCarDivDepot";
					divStyleBorderBottom = "MDRSBDBCarDivBottomBorderDepot";
				} else {
					status = "Stored";
					divStyle = "MDRSBDBCarDivInactive";
					divStyleBorderBottom = "MDRSBDBCarDivBottomBorderInactive";
					//parkedVehNum = parkedVehNum + 1;
				}
			} else {
				status = "Stored";
				divStyle = "MDRSBDBCarDivInactive";
				divStyleBorderBottom = "MDRSBDBCarDivBottomBorderInactive";
				//parkedVehNum = parkedVehNum + 1;
			}
		} else if (vehData.state === 2) {
			status = "Impound";
		}
		let plateImg = null;
		let plateTextColor = null;
		if (vehData.plateIndex === 0) {
			plateImg = "files/plate1.png";
			plateTextColor = "blue";
		} else if (vehData.plateIndex === 1) {
			plateImg = "files/plate2.png";
			plateTextColor = "yellow;"
		} else if (vehData.plateIndex === 2) {
			plateImg = "files/plate3.png";
			plateTextColor = "yellow";
		} else if (vehData.plateIndex === 3) {
			plateImg = "files/plate4.png";
			plateTextColor = "darkblue";
		} else if (vehData.plateIndex === 4) {
			plateImg = "files/plate1.png";
			plateTextColor = "darkblue";
		} else if (vehData.plateIndex === 5) {
			plateImg = "files/plate6.png";
			plateTextColor = "blue";
		}
		let vehLabel = vehData.vehicleLabel;
		if (vehLabel.length > 15) {
			vehLabel = vehLabel.slice(0, 15) + "...";
		}
		if (useCarImg) {
			checkIfImageExists(`https://docs.fivem.net/vehicles/${vehData.vehicle}.webp`, (exists) => {
				if (exists) {
					var vehiclesHTML = `
					<div class="MDRSBDBCarDiv ${divStyle}" id="MDRSBDBCarDiv-${vehData.plate}" onclick="clFunc('chooseCar', '${vehData.vehicle}', '${vehData.plate}', '${status}', '${vehData.engine}', '${vehData.body}', '${vehData.fuel}', '', '${vehData.index}', '${vehData.type}', '${vehData.depotPrice}')">
						<div id="MDRSBDBCarDivTop">
							<div id="MDRSBDBCarDivTopRectangle"></div><div id="MDRSBDBCarDivTopShared" class="${vehData.shared}"><i style="opacity: 0.42;" class="fas fa-key"></i></div>
							<img src="https://docs.fivem.net/vehicles/${vehData.vehicle}.webp" style="width: 8vw; position: relative; padding-top: 2vw;">
							<div id="MDRSBDBCarDivTopPlate" style="background-image: url(${plateImg}); color: ${plateTextColor};"><h4>${vehData.plate}</h4></div>
						</div>
						<div id="MDRSBDBCarDivBottom"><h4>${vehLabel}</h4><h4>${status}</h4></div>
						<div class="MDRSBDBCarDivBottomBorder ${divStyleBorderBottom}" id="MDRSBDBCarDivBottomBorder-${vehData.plate}"></div>
					</div>`;
					appendHtml(document.getElementById("MDRSBottomDivBottom"), vehiclesHTML);
				} else {
					if (useCustomCarImg) {
						var vehiclesHTML = `
						<div class="MDRSBDBCarDiv ${divStyle}" id="MDRSBDBCarDiv-${vehData.plate}" onclick="clFunc('chooseCar', '${vehData.vehicle}', '${vehData.plate}', '${status}', '${vehData.engine}', '${vehData.body}', '${vehData.fuel}', '', '${vehData.index}', '${vehData.type}', '${vehData.depotPrice}')">
							<div id="MDRSBDBCarDivTop">
								<div id="MDRSBDBCarDivTopRectangle"></div><div id="MDRSBDBCarDivTopShared" class="${vehData.shared}"><i style="opacity: 0.42;" class="fas fa-key"></i></div>
								<img src="cars/${vehData.vehicle}.png" style="width: 8vw; position: relative; padding-top: 2vw;">
								<div id="MDRSBDBCarDivTopPlate" style="background-image: url(${plateImg}); color: ${plateTextColor};"><h4>${vehData.plate}</h4></div>
							</div>
							<div id="MDRSBDBCarDivBottom"><h4>${vehLabel}</h4><h4>${status}</h4></div>
							<div class="MDRSBDBCarDivBottomBorder ${divStyleBorderBottom}" id="MDRSBDBCarDivBottomBorder-${vehData.plate}"></div>
						</div>`;
						appendHtml(document.getElementById("MDRSBottomDivBottom"), vehiclesHTML);
					} else {
						var vehiclesHTML = `
						<div class="MDRSBDBCarDiv ${divStyle}" id="MDRSBDBCarDiv-${vehData.plate}" onclick="clFunc('chooseCar', '${vehData.vehicle}', '${vehData.plate}', '${status}', '${vehData.engine}', '${vehData.body}', '${vehData.fuel}', '', '${vehData.index}', '${vehData.type}', '${vehData.depotPrice}')">
							<div id="MDRSBDBCarDivTop">
								<div id="MDRSBDBCarDivTopRectangle"></div><div id="MDRSBDBCarDivTopShared" class="${vehData.shared}"><i style="opacity: 0.42;" class="fas fa-key"></i></div>
								<img src="files/car.png" style="width: 6vw; position: relative; padding-top: 2vw;">
								<div id="MDRSBDBCarDivTopPlate" style="background-image: url(${plateImg}); color: ${plateTextColor};"><h4>${vehData.plate}</h4></div>
							</div>
							<div id="MDRSBDBCarDivBottom"><h4>${vehLabel}</h4><h4>${status}</h4></div>
							<div class="MDRSBDBCarDivBottomBorder ${divStyleBorderBottom}" id="MDRSBDBCarDivBottomBorder-${vehData.plate}"></div>
						</div>`;
						appendHtml(document.getElementById("MDRSBottomDivBottom"), vehiclesHTML);
					}
				}
			});
		} else {
			var vehiclesHTML = `
			<div class="MDRSBDBCarDiv ${divStyle}" id="MDRSBDBCarDiv-${vehData.plate}" onclick="clFunc('chooseCar', '${vehData.vehicle}', '${vehData.plate}', '${status}', '${vehData.engine}', '${vehData.body}', '${vehData.fuel}', '', '${vehData.index}', '${vehData.type}', '${vehData.depotPrice}')">
				<div id="MDRSBDBCarDivTop">
					<div id="MDRSBDBCarDivTopRectangle"></div><div id="MDRSBDBCarDivTopShared" class="${vehData.shared}"><i style="opacity: 0.42;" class="fas fa-key"></i></div>
					<img src="files/car.png" style="width: 6vw; position: relative; padding-top: 2vw;">
					<div id="MDRSBDBCarDivTopPlate" style="background-image: url(${plateImg}); color: ${plateTextColor};"><h4>${vehData.plate}</h4></div>
				</div>
				<div id="MDRSBDBCarDivBottom"><h4>${vehLabel}</h4><h4>${status}</h4></div>
				<div class="MDRSBDBCarDivBottomBorder ${divStyleBorderBottom}" id="MDRSBDBCarDivBottomBorder-${vehData.plate}"></div>
			</div>`;
			appendHtml(document.getElementById("MDRSBottomDivBottom"), vehiclesHTML);
		}
	});


	// totalVehNum = totalVehNum + 1;
	// document.getElementById("MDRSBottomDivBottom").innerHTML = vehicles.map((vehicleData) => {
	// 	var {state, depotPrice, type, plateIndex, vehicleLabel, vehicle, plate, engine, body, fuel, index, shared} = vehicleData;
	// 	let status;
	// 	let isDepotPrice5 = false;
	// 	let divStyle = "MDRSBDBCarDivInactive";
	// 	let divStyleBorderBottom = "MDRSBDBCarDivBottomBorderInactive";
	// 	if (state === 0) {
	// 		if (depotPrice && depotPrice > 0) {
	// 			isDepotPrice5 = true;
	// 			divStyle = "MDRSBDBCarDivDepot";
	// 			if (type === "public") {
	// 				status = "Depot";
	// 				divStyleBorderBottom = "MDRSBDBCarDivBottomBorderDepot";
	// 			} else if (type === "depot") {
	// 				status = "$" + depotPrice.toFixed(0);
	// 				divStyleBorderBottom = "MDRSBDBCarDivBottomBorderDepot";
	// 			} else {
	// 				status = "Out";
	// 				divStyleBorderBottom = "MDRSBDBCarDivBottomBorderOut";
	// 			}
	// 		} else {
	// 			divStyle = "MDRSBDBCarDivOut";
	// 			divStyleBorderBottom = "MDRSBDBCarDivBottomBorderOut";
	// 			status = "Out";
	// 		}
	// 	} else if (state === 1) {
	// 		if (depotPrice && depotPrice > 0) {
	// 			isDepotPrice5 = true;
	// 			if (type === "depot") {
	// 				status = "$" + depotPrice.toFixed(0);
	// 				divStyle = "MDRSBDBCarDivDepot";
	// 				divStyleBorderBottom = "MDRSBDBCarDivBottomBorderDepot";
	// 			} else if (type === "public") {
	// 				status = "Depot";
	// 				divStyle = "MDRSBDBCarDivDepot";
	// 				divStyleBorderBottom = "MDRSBDBCarDivBottomBorderDepot";
	// 			} else {
	// 				status = "Stored";
	// 				divStyle = "MDRSBDBCarDivInactive";
	// 				divStyleBorderBottom = "MDRSBDBCarDivBottomBorderInactive";
	// 				//parkedVehNum = parkedVehNum + 1;
	// 			}
	// 		} else {
	// 			status = "Stored";
	// 			divStyle = "MDRSBDBCarDivInactive";
	// 			divStyleBorderBottom = "MDRSBDBCarDivBottomBorderInactive";
	// 			//parkedVehNum = parkedVehNum + 1;
	// 		}
	// 	} else if (state === 2) {
	// 		status = "Impound";
	// 	}
	// 	let plateImg = null;
	// 	let plateTextColor = null;
	// 	if (plateIndex === 0) {
	// 		plateImg = "files/plate1.png";
	// 		plateTextColor = "blue";
	// 	} else if (plateIndex === 1) {
	// 		plateImg = "files/plate2.png";
	// 		plateTextColor = "yellow;"
	// 	} else if (plateIndex === 2) {
	// 		plateImg = "files/plate3.png";
	// 		plateTextColor = "yellow";
	// 	} else if (plateIndex === 3) {
	// 		plateImg = "files/plate4.png";
	// 		plateTextColor = "darkblue";
	// 	} else if (plateIndex === 4) {
	// 		plateImg = "files/plate1.png";
	// 		plateTextColor = "darkblue";
	// 	} else if (plateIndex === 5) {
	// 		plateImg = "files/plate6.png";
	// 		plateTextColor = "blue";
	// 	}
	// 	let vehLabel = vehicleLabel;
	// 	if (vehLabel.length > 15) {
	// 		vehLabel = vehLabel.slice(0, 15) + "...";
	// 	}
	// 	if (useCarImg) {
	// 		let existsImg = false;
	// 		checkIfImageExists(`https://docs.fivem.net/vehicles/${vehicle}.webp`, (exists) => {
	// 			existsImg = exists;
	// 		});
	// 		if (existsImg) {
	// 			return (
	// 			`<div class="MDRSBDBCarDiv ${divStyle}" id="MDRSBDBCarDiv-${plate}" onclick="clFunc('chooseCar', '${vehicle}', '${plate}', '${status}', '${engine}', '${body}', '${fuel}', '', '${index}', '${type}', '${depotPrice}')">
	// 				<div id="MDRSBDBCarDivTop">
	// 					<div id="MDRSBDBCarDivTopRectangle"></div><div id="MDRSBDBCarDivTopShared" class="${shared}"><i style="opacity: 0.42;" class="fas fa-key"></i></div>
	// 					<img src="https://docs.fivem.net/vehicles/${plate}.webp" style="width: 8vw; position: relative; padding-top: 2vw;">
	// 					<div id="MDRSBDBCarDivTopPlate" style="background-image: url(${plateImg}); color: ${plateTextColor};"><h4>${plate}</h4></div>
	// 				</div>
	// 				<div id="MDRSBDBCarDivBottom"><h4>${vehLabel}</h4><h4>${status}</h4></div>
	// 				<div class="MDRSBDBCarDivBottomBorder ${divStyleBorderBottom}" id="MDRSBDBCarDivBottomBorder-${vehicle}"></div>
	// 			</div>`
	// 			)
	// 		} else {
	// 			if (useCustomCarImg) {
	// 				return ( 
	// 				`<div class="MDRSBDBCarDiv ${divStyle}" id="MDRSBDBCarDiv-${plate}" onclick="clFunc('chooseCar', '${vehicle}', '${plate}', '${status}', '${engine}', '${body}', '${fuel}', '', '${index}', '${type}', '${depotPrice}')">
	// 					<div id="MDRSBDBCarDivTop">
	// 						<div id="MDRSBDBCarDivTopRectangle"></div><div id="MDRSBDBCarDivTopShared" class="${shared}"><i style="opacity: 0.42;" class="fas fa-key"></i></div>
	// 						<img src="cars/${plate}.png" style="width: 7vw; position: relative; padding-top: 2vw;">
	// 						<div id="MDRSBDBCarDivTopPlate" style="background-image: url(${plateImg}); color: ${plateTextColor};"><h4>${plate}</h4></div>
	// 					</div>
	// 					<div id="MDRSBDBCarDivBottom"><h4>${vehLabel}</h4><h4>${status}</h4></div>
	// 					<div class="MDRSBDBCarDivBottomBorder ${divStyleBorderBottom}" id="MDRSBDBCarDivBottomBorder-${plate}"></div>
	// 				</div>`
	// 				)
	// 			} else {
	// 				return ( 
	// 				`<div class="MDRSBDBCarDiv ${divStyle}" id="MDRSBDBCarDiv-${plate}" onclick="clFunc('chooseCar', '${vehicle}', '${plate}', '${status}', '${engine}', '${body}', '${fuel}', '', '${index}', '${type}', '${depotPrice}')">
	// 					<div id="MDRSBDBCarDivTop">
	// 						<div id="MDRSBDBCarDivTopRectangle"></div><div id="MDRSBDBCarDivTopShared" class="${shared}"><i style="opacity: 0.42;" class="fas fa-key"></i></div>
	// 						<img src="files/car.png" style="width: 6vw; position: relative; padding-top: 2vw;">
	// 						<div id="MDRSBDBCarDivTopPlate" style="background-image: url(${plateImg}); color: ${plateTextColor};"><h4>${plate}</h4></div>
	// 					</div>
	// 					<div id="MDRSBDBCarDivBottom"><h4>${vehLabel}</h4><h4>${status}</h4></div>
	// 					<div class="MDRSBDBCarDivBottomBorder ${divStyleBorderBottom}" id="MDRSBDBCarDivBottomBorder-${plate}"></div>
	// 				</div>`
	// 				)
	// 			}
	// 		}
	// 	} else {
	// 		return ( 
	// 			`<div class="MDRSBDBCarDiv ${divStyle}" id="MDRSBDBCarDiv-${plate}" onclick="clFunc('chooseCar', '${vehicle}', '${plate}', '${status}', '${engine}', '${body}', '${fuel}', '', '${index}', '${type}', '${depotPrice}')">
	// 			<div id="MDRSBDBCarDivTop">
	// 				<div id="MDRSBDBCarDivTopRectangle"></div><div id="MDRSBDBCarDivTopShared" class="${shared}"><i style="opacity: 0.42;" class="fas fa-key"></i></div>
	// 				<img src="files/car.png" style="width: 6vw; position: relative; padding-top: 2vw;">
	// 				<div id="MDRSBDBCarDivTopPlate" style="background-image: url(${plateImg}); color: ${plateTextColor};"><h4>${plate}</h4></div>
	// 			</div>
	// 			<div id="MDRSBDBCarDivBottom"><h4>${vehLabel}</h4><h4>${status}</h4></div>
	// 			<div class="MDRSBDBCarDivBottomBorder ${divStyleBorderBottom}" id="MDRSBDBCarDivBottomBorder-${plate}"></div>
	// 		</div>`
	// 		)
	// 	}
	// 	//document.getElementById("MDRSTDCDiv2").innerHTML=parkedVehNum + "/" + totalVehNum;
	// }).join('');
}

function findCarByPartialLabel(vehicles, partialLabel) {
    const matchingLabels = vehicles.filter(vehicle => 
        vehicle.vehicleLabel.toLowerCase().includes(partialLabel.toLowerCase())
    )
    return matchingLabels;
}

function checkIfImageExists(url, callback) {
	const img = new Image();
	img.src = url;
	if (img.complete) {
		callback(true);
	} else {
		img.onload = () => {
			callback(true);
		};
		img.onerror = () => {
			callback(false);
		};
	}
}