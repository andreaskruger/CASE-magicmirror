songsPlayd = 0

Module.register("CASEspotify", {
	// Default module config.
	defaults: {
		text: "Hello World!"

	},
	musicMessage:"Spotify!",
	start: function(){
		const ws = new WebSocket("ws://192.168.1.124:8081/events")
		ws.addEventListener("message",(message)=>{
			songsPlayd++
			this.musicMessage = JSON.parse(message.data)
			this.updateDom()
		})
	},
	
	getTemplate: function () {
		return "CASEspotify.njk";
	},

	getTemplateData: function () {
		return this.config;
	},
	getStyles: function(){
		return["style.css","font-awesome.css"];
	},
	getDom: function(){
		
		var wrapper = document.createElement("div");
		var image = document.createElement("img");
		var track = document.createElement("h2");
		var volume = document.createElement("input");
		var soundIcon = document.createElement("span");
		
		
		soundIcon.className = "fa fa-volume-up";
		track.innerHTML = this.musicMessage.track.title + " - " + this.musicMessage.track.artist.join(", ")
		image.src = this.musicMessage.track.artUrl
		volume.type = "range"
		volume.value = this.musicMessage.volume
		wrapper.appendChild(image);
		wrapper.appendChild(track);
		wrapper.appendChild(soundIcon);
		wrapper.appendChild(volume);
		
		return wrapper
	}
});
