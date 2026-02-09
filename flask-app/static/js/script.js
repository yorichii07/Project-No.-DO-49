const questions = [
    { q: "Python is a?", options: ["Snake", "Programming Language"], ans: 1 },
    { q: "Flask is used for?", options: ["Web Development", "Gaming"], ans: 0 },
    { q: "HTML stands for?", options: ["Hyper Text Markup Language", "High Tool ML"], ans: 0 },
    { q: "CSS is used for?", options: ["Logic", "Styling"], ans: 1 },
    { q: "JavaScript runs in?", options: ["Browser", "Compiler"], ans: 0 },
    { q: "Git is used for?", options: ["Testing", "Version Control"], ans: 1 },
    { q: "Which is backend?", options: ["HTML", "Python"], ans: 1 },
    { q: "Flask written in?", options: ["Java", "Python"], ans: 1 },
    { q: "Which is NOT DB?", options: ["MySQL", "HTML"], ans: 1 },
    { q: "HTTP stands for?", options: ["Hyper Text Transfer Protocol", "High Transfer"], ans: 0 }
];

let index = 0;
let score = 0;
let timeLeft = 10;
let timer;

loadQuestion();

function loadQuestion() {
    if (index >= questions.length) {
        showResult();
        return;
    }

    document.getElementById("qno").innerText =
        `Question ${index + 1} / ${questions.length}`;

    document.getElementById("question-box").innerText =
        questions[index].q;

    let optionsHTML = "";
    questions[index].options.forEach((opt, i) => {
        optionsHTML += `
            <label>
                <input type="radio" name="option" value="${i}">
                ${opt}
            </label>
        `;
    });

    document.getElementById("options").innerHTML = optionsHTML;

    resetTimer();
}

function resetTimer() {
    clearInterval(timer);
    timeLeft = 10;
    document.getElementById("time").innerText = timeLeft;

    timer = setInterval(() => {
        timeLeft--;
        document.getElementById("time").innerText = timeLeft;

        if (timeLeft === 0) {
            nextQuestion();
        }
    }, 1000);
}

function nextQuestion() {
    clearInterval(timer);

    let selected = document.querySelector('input[name="option"]:checked');
    if (selected && parseInt(selected.value) === questions[index].ans) {
        score++;
    }

    index++;
    loadQuestion();
}

function showResult() {
    document.querySelector(".quiz-container").innerHTML = `
        <h1>Quiz Completed 🎉</h1>
        <p id="result">Your Score: ${score} / ${questions.length}</p>
    `;
}
