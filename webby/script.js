

const button = document.querySelector("#btn_clicko")
const btn_move = document.querySelector("#btn_move")
const header = document.querySelector("#txt_title")
const image = document.querySelector("#img_wallpaper")


button.addEventListener("click", () => {
	// alert("JavaScript kiddo")
	header.textContent = "WEBBY TECHO"


	paragraph = document.createElement("p")
	paragraph.textContent = "Dynamic Paragraph"

	document.body.appendChild(paragraph)
} )


btn_move.addEventListener("click", () => {

	move_img()
})

pos_x = 0

document.addEventListener("keydown", (event) => {
    if (event.key === "ArrowRight") {
        pos_x += 10;
        image.style.left = `${pos_x}px`;
    }

    if (event.key === "ArrowLeft") {
        pos_x -= 10;
        image.style.left = `${pos_x}px`;
    }

    console.log("pos: " + pos_x)
});


function move_img() {
	image.style.marginLeft += 10
	//image.width = 256
}


