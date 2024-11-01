document.addEventListener("DOMContentLoaded", () => {
    // sentences for headline
    const sentences = [
        "Noodle is a self-hosted platform aimed at open-source developers, where their supporters can contribute small donations.",
        "Noodle provides a simple, secure, and cheap way for developers to receive financial backing.",
        "Try it yourself!"
    ];

    let index = 0;
    // Function to show each sentence with fade effect
    function showNextSentence() {
        const textElement = document.getElementById("headline");

        textElement.classList.add("fade-out");

        setTimeout(() => {
            textElement.textContent = sentences[index];
            textElement.classList.remove("fade-out");
            textElement.classList.add("fade-in");

            index = (index + 1) % sentences.length;

            setTimeout(() => {
                textElement.classList.remove("fade-in");
                showNextSentence();
            }, 5000); // Duration of each sentence display
        }, 500); // Fade-out transition duration
    }

    showNextSentence();
})
