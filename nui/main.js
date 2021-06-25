var blockSelect = false;

window.addEventListener("message", (event) => {
	if (event.data.action === "abrir") {
		$("#actionmenu").show();
		$("#vipModal").show();
		$("#error-message").hide();
		$("#vehiclesModal").hide();
	} else if (event.data.action === "fechar") {
		$("#actionmenu").hide();
		$("#vipModal").hide();
		$("#vehiclesModal").hide();
	}
});

document.onkeyup = function (data) {
	if (data.which == 27) if ($("#actionmenu").is(":visible")) $.post(`http://${GetParentResourceName()}/close`, {});
};

var tempCode = "";
$("#validate-button").on("click", () => {
	const code = $("#code-field").val().toUpperCase();

	const button = $("#validate-button");
	button.prop("disabled", true);
	button.html(`<img src="imgs/loading.svg" style="height: 40px; width: 60px" alt="Carregando"/>`);

	$("#vehicleList").html("");

	$.post(`http://${GetParentResourceName()}/validateCode`, JSON.stringify({ code }), (data) => {
		data = JSON.parse(data)
		tempCode = code;
		if (data.status == 200) {
			for(var veh in data.vehicles) {
				veh = data.vehicles[veh]
				$("#vehicleList").append(`
					<div class="vehicle card mb-3" style="width: 540px; height: 100px;" data-vehicle="${veh.model}">
						<div class="row g-0">
							<div class="col-md-4">
								<img src="${config.imagens}/${veh.model}.png" class="h-100 w-100 img-fluid rounded-start" onerror="if (this.src != 'imgs/default.png') this.src = 'imgs/default.png';" />
							</div>
							<div class="col-md-8">
								<div class="card-body">
									<h5 class="card-title fw-bolder">${veh.name.toUpperCase()}</h5>
									<p class="card-text fw-normal">Este veículo pertence aos <b>${veh.type}</b></p>
								</div>
							</div>
						</div>
					</div>
				`);
			}
		} else {
			$("#code-field").val('');
			$("#error-message").show();
			$("#error-message").text("O código inserido não é válido!");
			$("#error-message").fadeOut(5000, function() {
				$("#validate-button").prop("disabled", false);
				$("#validate-button").html("Validar");
			})
			return;
		}
		$("#validate-button").prop("disabled", false);
		$("#validate-button").html("Validar");
		$("#vipModal").hide();
		$("#vehiclesModal").show();
	});
});
				
$("#vehicleList").on("click", ".vehicle", function () {
	if(blockSelect) return;
		
	$(this).toggleClass("vehicle-active");
});

$("#selectVehicles-button").on("click", () => {
	blockSelect = true;
		
	const code = tempCode;
	const button = $("#selectVehicles-button");
	button.prop("disabled", true);
	button.html(`<img src="imgs/loading.svg" style="height: 40px; width: 60px" alt="Carregando"/>`);

	var vehicles = []
	$(".vehicle-active").each(function() {
		vehicles.push($(this).data("vehicle"));
	});

	$.post(`http://${GetParentResourceName()}/selectVehicles`, JSON.stringify({ code, vehicles }), (responseCode) => {
		if(responseCode == 200) {
			$.post(`http://${GetParentResourceName()}/close`, {});
			$("#vehicleList").html("");
		}
		
		// $.post(`http://${GetParentResourceName()}/close`, {});
		$("#selectVehicles-button").html("Pronto");
		$("#selectVehicles-button").prop("disabled", false);
		
		blockSelect = false;
	});
});