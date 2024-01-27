function changeActiveInfoDisplay(clickedButton) {
    // Remove "active" class from all buttons
    const buttons = document.querySelectorAll('.info-selector');
    buttons.forEach(function(button) {
      button.classList.remove('content-selector-active');
    });
  
    // Add "active" class to the clicked button
    clickedButton.classList.add('content-selector-active');

    var infoDisplayBox = "";
    switch (clickedButton.textContent) {
        case ("Employment"):
            infoDisplayBox = "info-display-box-employment";
            break;
        case ("Contract History"):
            infoDisplayBox = "info-display-box-contract";
            break;
        case ("Certifications"):
            infoDisplayBox = "info-display-box-certifications";
            break;
        case ("Other Projects"):
            infoDisplayBox = "info-display-box-otherprojects";
            break;
    };
    console.log(infoDisplayBox);

    // Remove "active" class from all info sections
    const sections = document.querySelectorAll('.content-section');
    console.log(sections);

    sections.forEach(function(section) {
        console.log(section);
        section.classList.remove('info-display-active');
    });

    // Get appropriate section to display
    activeSection = document.getElementById(infoDisplayBox);
  
    // Add "active" class to the appropriate section for button clicked
    activeSection.classList.add('info-display-active');
  };