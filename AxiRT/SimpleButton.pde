
// These keep track of all the buttons that there are
static ArrayList buttonList;  // List of all buttons 

// Function to draw all of the buttons at once
static void DrawButtons(PGraphics buffer) {
  if (buttonList == null) {
    return;
  }

  for (int i = buttonList.size()-1; i >= 0; i--) { 
    SimpleButton button = (SimpleButton) buttonList.get(i);
    button.draw(buffer);
  }
}


// A simple text button class, that allows you to specify a text label and x&y
// coordinates.
class SimpleButton
{
  String label;
  float posX;
  float posY;
  float buttonWidth;
  float buttonHeight;

  // These are optional attributes
  PFont font;
  int fontSize;
  color displayColor;
  color highlightColor; 


  SimpleButton( String label, int posX, int posY ) {
    initButton( label, posX, posY, (PFont)null, 0, color(255, 255, 255, 128), color(255));
  }

  SimpleButton( String label, int posX, int posY, 
  PFont font, int fontSize, 
  color displayColor, color highlightColor) {
    initButton( label, posX, posY, font, fontSize, displayColor, highlightColor );
  }

  void initButton( String label, int posX, int posY, 
  PFont font, int fontSize, 
  int displayColor, int highlightColor ) {
    if (buttonList == null) {
      // If this is the first button, we need to create a list to store them in.
      buttonList = new ArrayList();
    }

    this.posX = posX;
    this.posY = posY;
    this.font = font;
    this.fontSize = fontSize;
    this.displayColor = displayColor;
    this.highlightColor = highlightColor; 
    updateLabel(label);

    buttonList.add(this);
  }

  void draw(PGraphics b) {

    // Determine
    if ( isSelected() )
    {
      b.fill(highlightColor);
    }
    else {
      b.fill(displayColor);
    }

    if ( font != null) {
      b.textFont( font, fontSize );
    }

    b.text(label, posX, posY);
  }

  void delete() {
    // Delete this button
    // TODO: Find self in button list and remove.
  }

  void updateLabel(String label) {
    this.label = label;

    if ( font != null) {
      textFont( font, fontSize );
    }

    buttonWidth = textWidth(label);
    buttonHeight = textAscent();
  }

  boolean isSelected() {
    return ( overRect(posX, posY - buttonHeight, buttonWidth, buttonHeight) );
  }

  boolean overRect(float x, float y, float width, float height) 
  {
    if (mouseX >= x && mouseX <= x+width &&  mouseY >= y && mouseY <= y+height) 
      return true; 
    else 
      return false;
  }
}