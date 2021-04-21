//Maximillian Marciel

//Draws a US map that allows the user to derive election result data via interaction with the map.
//Multi-paneled, will draw an interactive map and bar charts.
//Will draw the parties' bar chart of dynamic widths according to the number of parties.
//Uses freely available data from MIT electionlab. Can be found at: https://electionlab.mit.edu/data

//--- CLASSES ---------------------------------------------------------------------------------

//Nodes that the user interacts with on the map. Has a name, xpos, and ypos.
public class node
{
  public String name = "";  //e.g. "Alabama", "Rhode Island"
  public float  xpos = 0;   //position in the x axis
  public float  ypos = 0;   //position in the y axis
  public float  extent = 0; //size of the node on screen
}

//--- GLOBALS ---------------------------------------------------------------------------------

//Offset for the map's placement on the screen. The number represents coordinates, or pixels.
final float mapOffsetX = 25;
final float mapOffsetY = 270;

//Offset for the graph's placement on the screen
final float graphOffsetX = 1025;
final float graphOffsetY = 0;

//All nodes and their associated information
final int stateCount = 50;
node[] nodeList = new node[stateCount];

//Small offset for whitespace to be drawn to make the graph more even
final float whitespaceBuffer = 70;

//The ratio of space on the right dedicated not to graphs, but to names.
final float namespaceRatio = 0.2f;

//The current year that is being displayed, as well as current state. Initialized to these values.
int currentYear = 2016;
String currentState = "Washington";

//Font variable
PFont f;

//Table
Table csvData;

//--- FUNCTIONS ---------------------------------------------------------------------------------

//TESTING ONLY
//Fortunately, this program is able to avoid drawing the image over and over per frame, and therefore
//is very efficient with CPU use, only drawing what's necessary when the user asks for it. This should
//not be used, unless for testing purposes.
void draw()
{
  //detectNodeCollision();
  //drawCurrentYear();
}

//***************************************************************

//Run once at the beginning
void setup()
{
  //Size of the screen is standard resolution, 1920x1080
  size(1920,1080);
  
  //Background is white
  background(255);
  
  //Set up the font
  f = createFont("Arial",16,true); // Arial, 16 point, anti-aliasing on
  textFont(f,36);
  
  //Refresh the map so that it's drawn to the screen on startup
  drawGraph(currentState);
  
  //Load the table into the table variable
  csvData = loadTable("pres.csv", "header");
  
}

//***************************************************************

//Activates when mouse is clicked
void mouseClicked()
{
  //See where the user clicked
  String clickResult = detectNodeCollision();
  
  //If it is not none, then draw the graph for that node.
  if (!clickResult.equals("None"))
  {
    currentState = clickResult;
    drawGraph(clickResult);
  }
}

//***************************************************************

//Gets the minimum votes for a state
int getMinVotesForState(String stateName, int maxVotes)
{
  int currVotes = maxVotes;
  for (TableRow row : csvData.rows())
  {
    int votes = row.getInt("candidatevotes");
    String state = row.getString("state");
    int year = row.getInt("year");
    
    if ((currVotes > votes) && stateName.equals(state) && (year == currentYear))
    {
      currVotes = votes;
    }
  }
  return currVotes;
}

//***************************************************************

//Gets the maximum votes for a state
int getMaxVotesForState(String stateName)
{
  int maxVotes = 0;
  for (TableRow row : csvData.rows())
  {
    int votes = row.getInt("candidatevotes");
    String state = row.getString("state");
    int year = row.getInt("year");
    
    if ((maxVotes < votes) && stateName.equals(state) && (year == currentYear))
    {
      maxVotes = votes;
    }
  }
  return maxVotes;
}

//***************************************************************

//Gets the amount of parties voted for in the state
int getPartyNumberForState(String stateName)
{
  //Count of how many parties in the state
  int count = 0;
  
  for (TableRow row : csvData.rows())
  {
    String state = row.getString("state");
    int year = row.getInt("year");
    
    if ((year == currentYear) && (state.equals(stateName)))
    {
      count++;
    }
  }
  return count;
}

//***************************************************************

//Draws the graph on the right side of the screen
void drawGraph(String stateName)
{
  //Refreshes the map so the background is applied to clear the 
  //right side of the screen, redrawing the other elements.
  refreshMap();
  
  //Draw the state at the top as text
  textAlign(CENTER);
  textFont(f,36);
  text(currentState, 1500, 45);
  
  //Draw the legend at the bottom
  image(loadImage("legend.jpg"), graphOffsetX + 320,  graphOffsetY + 880);
  
  //Information related to where to begin drawing the rectangles for the graph. Initialized
  //to be in the right place, then moved as required.
  float PosX = graphOffsetX + whitespaceBuffer;
  float PosY = height - (namespaceRatio * height);
  
  //Basic preliminary information needed to calculate the graph's deserved space
  int partyNumber = getPartyNumberForState(stateName);
  int maxVotes = getMaxVotesForState(stateName);
  int minVotes = getMinVotesForState(stateName, maxVotes);
  float heightScaleFactor = (PosY - whitespaceBuffer) / maxVotes;
  float rectLength =  ((width - PosX) / 2) / partyNumber; //Divided by 2 because of whitespace.
  
  //Set up the font
  textFont(f,14);
  fill(0);
  
  //Round the max votes to the nearest 100th
  int roundedMaxVotes = round10(maxVotes);
  
  //Draw the legend
  text(roundedMaxVotes, graphOffsetX + 35, 75); //Top
  text(0, graphOffsetX + 35, 865); //Bottom
  text(roundedMaxVotes / 2, graphOffsetX + 35, 465); //Middle
  text(roundedMaxVotes / 4, graphOffsetX + 35, 650); //Bottom middle
  text((roundedMaxVotes + (roundedMaxVotes / 2)) / 2, graphOffsetX + 35, 275); //Top middle
  
  //Draw the lines associated with the legend
  line(graphOffsetX + whitespaceBuffer, whitespaceBuffer, graphOffsetX + 1000, whitespaceBuffer); //Top
  line(graphOffsetX + whitespaceBuffer, 460, graphOffsetX + 1000, 460); //Middle
  line(graphOffsetX + whitespaceBuffer, 865, graphOffsetX + 1000, 865); //Bottom
  line(graphOffsetX + whitespaceBuffer, 645, graphOffsetX + 1000, 645); //Bottom middle
  line(graphOffsetX + whitespaceBuffer, 270, graphOffsetX + 1000, 270); //Top middle
  
  //Loop over the entire state to construct the rectangle
  for (TableRow row : csvData.rows())
  {
    //Make sure that we only draw for the current state at this year.
    int year = row.getInt("year");
    String state = row.getString("state");
    if (stateName.equals(state) && year == currentYear)
    {
      int votes = row.getInt("candidatevotes");
      String party = row.getString("party");
      
      //Color bar according to its party.
      if (party.equals("democrat") || party.equals("democratic-farmer-labor"))
      {
        fill(56,85,255); //Fill blue
      }
      else if (party.equals("republican"))
      {
        fill(255,50,50); //Fill red
      }
      else if (party.equals("libertarian"))
      {
        fill(255, 216, 0); //Fill yellow
      }
      else if (party.contains("constitution"))
      {
        fill(255); //Fill white
      }
      else if (party.equals("green"))
      {
        fill(0,210,25); //Fill green
      }
      else //else, mark black
      {
        fill(0); //Fill black
      }
      
      //Draw the bar
      rect(PosX, PosY, rectLength, -(votes * heightScaleFactor));
      
      //Move double forward to add whitespace and prep to draw next one
      PosX += (rectLength * 2);
    }
  }
}

int round10(final int n) {
  return (n + 500) / 1000 * 1000;
}

//***************************************************************

//Takes all nodes and then draws them to the screen
void drawAllNodes()
{ 
  int maxVotes = 0;
  String maxParty = "";
  csvData = loadTable("pres.csv", "header");
  
  //For all the nodes
  for (int i = 0; i < stateCount; i++)
  {
    maxVotes = 0;
    maxParty = "";
    
    //Figure out the filling of the node based on who won the election.
    //Only democrat/republican is considered (blue/red) because there is no case
    //of a third party winning an entire state.
    for (TableRow row : csvData.rows())
    {
      int year = row.getInt("year");
      String state = row.getString("state");
      String party = row.getString("party");
      int votes = row.getInt("candidatevotes");
      
      //If the state and year are the same, then see which party had the most votes.
      if ((year == currentYear) && (state.equals(nodeList[i].name)))
      {
        if (votes > maxVotes)
        {
          maxVotes = votes;
          maxParty = party;
        }
      }
    }
    
    //Color node according to its winning party, maxparty.
    if (maxParty.equals("democrat") || maxParty.equals("democratic-farmer-labor"))
    {
      fill(56,85,255); //Fill blue
    }
    else if (maxParty.equals("republican"))
    {
      fill(255,50,50); //Fill red
    }
    else //If a third party (just in case)
    {
      fill(0,210,25); //Fill green
    }
    
    //Draw the node to the screen at its x, y, and extent
    circle(nodeList[i].xpos, nodeList[i].ypos, nodeList[i].extent);
  }
}

//***************************************************************

//Initializes each individual node so they are not null.
void initNodes()
{
  //For all the nodes
  for (int i = 0; i < stateCount; i++)
  {
    nodeList[i] = new node();
  }
}

//***************************************************************

//Assigns the parameters to the node itself.
void assignNode(String n, float x, float y, float e, int nodeNumber)
{
  nodeList[nodeNumber].name = n;
  nodeList[nodeNumber].xpos = x;
  nodeList[nodeNumber].ypos = y;
  nodeList[nodeNumber].extent = e;
}

//***************************************************************

//Draw the current year to the screen
void drawCurrentYear()
{
  fill(0);
  textAlign(RIGHT);
  textFont(f,36);
  text(currentYear, 500, 200);
}

//***************************************************************

//Sees if the mouse is located on a node, and returns the name.
String detectNodeCollision()
{ 
  //For all the nodes
  for (int i = 0; i < stateCount; i++)
  {
    //Checks for mouse collision with a node
    if (dist(mouseX, mouseY, nodeList[i].xpos, nodeList[i].ypos) < nodeList[i].extent)
    { 
      //Return the name
      return nodeList[i].name;
    }
  }
  //if it doesn't return the proper name after looping over all nodes,
  //then return none.
  return "None";
}


//***************************************************************

//Loads a new map to the screen and all nodes in order to "refresh" the page.
void refreshMap()
{
  //Clearscreen
  background(255);
  
  //Load the USA map once to the blank screen. Doesn't need updating once it is drawn.
  image(loadImage("blank_us.jpg"), mapOffsetX,  mapOffsetY);
  
  //Create nodes (states), then draw them to the map.
  initNodes();
  assignStates();
  drawAllNodes();
  
  //Draw the year to the map
  drawCurrentYear();
  
  //Draw the divisor line between the windows as well as the top border
  fill(0);
  rect(graphOffsetX, 0, 5, height);
  rect(0, 0, width, 2);
}
//***************************************************************

//Triggers whenever a key is pressed. Valid keys are right and left arrow.
void keyPressed()
{
  //If the key is a non-ASCII character
  if (key == CODED)
  { 
    //If it's left arrow (Decrement)
    if (keyCode == LEFT)
    {
      currentYear -= 4; //Decrement the election cycle
      if (currentYear < 1976) //If it goes over, reset it.
      {
        currentYear = 2016;
      }
    }
    //If it's right arrow (Increment)
    if (keyCode == RIGHT)
    {
      currentYear += 4; //Increment election cycle
      if (currentYear > 2016) //If it goes over, reset it.
      {
        currentYear = 1976;
      }
    }
    
    //Draw the graph/map
    drawGraph(currentState);
  }
}

//***************************************************************

//Very long and messy, manually inputs all of the nodes' info into the list.
//This solution, although very long and arduous, is preferable to the time it would
//take to create a dynamic solution - especially since the dynamic solution would also
//not work for any alternative images of the United States itself.
void assignStates()
{
  fill(255, 0, 0);
  assignNode("Washington", mapOffsetX + 110, mapOffsetY + 50, 25, 0);
  assignNode("Oregon", mapOffsetX + 90, mapOffsetY + 128, 25, 1);
  assignNode("California", mapOffsetX + 60, mapOffsetY + 275, 25, 2);
  assignNode("Nevada", mapOffsetX + 120, mapOffsetY + 240, 25, 3);
  assignNode("Idaho", mapOffsetX + 185, mapOffsetY + 155, 25, 4);
  assignNode("Montana", mapOffsetX + 280, mapOffsetY + 90, 25, 5);
  assignNode("Arizona", mapOffsetX + 195, mapOffsetY + 375, 25, 6);
  assignNode("Utah", mapOffsetX + 220, mapOffsetY + 260, 25, 7);
  assignNode("Wyoming", mapOffsetX + 295, mapOffsetY + 185, 25, 8);
  assignNode("Colorado", mapOffsetX + 320, mapOffsetY + 280, 25, 9);
  assignNode("New Mexico", mapOffsetX + 300, mapOffsetY + 380, 25, 10);
  assignNode("Texas", mapOffsetX + 440, mapOffsetY + 460, 25, 11);
  assignNode("Oklahoma", mapOffsetX + 470, mapOffsetY + 370, 25, 12);
  assignNode("Kansas", mapOffsetX + 450, mapOffsetY + 300, 25, 13);
  assignNode("Nebraska", mapOffsetX + 425, mapOffsetY + 230, 25, 14);
  assignNode("South Dakota", mapOffsetX + 420, mapOffsetY + 160, 25, 15);
  assignNode("South Dakota", mapOffsetX + 420, mapOffsetY + 92, 25, 16);
  assignNode("Minnesota", mapOffsetX + 510, mapOffsetY + 120, 25, 17);
  assignNode("Iowa", mapOffsetX + 530, mapOffsetY + 215, 25, 18);
  assignNode("Missouri", mapOffsetX + 555, mapOffsetY + 300, 25, 19);
  assignNode("Arkansas", mapOffsetX + 555, mapOffsetY + 385, 25, 20);
  assignNode("Louisiana", mapOffsetX + 559, mapOffsetY + 470, 25, 21);
  assignNode("Mississippi", mapOffsetX + 612, mapOffsetY + 420, 25, 22);
  assignNode("Alabama", mapOffsetX + 667, mapOffsetY + 420, 25, 23);
  assignNode("Georgia", mapOffsetX + 735, mapOffsetY + 415, 25, 24);
  assignNode("Florida", mapOffsetX + 782, mapOffsetY + 510, 25, 25);
  assignNode("South Carolina", mapOffsetX + 780, mapOffsetY + 380, 25, 26);
  assignNode("North Carolina", mapOffsetX + 805, mapOffsetY + 335, 25, 27);
  assignNode("Tennessee", mapOffsetX + 670, mapOffsetY + 350, 25, 28);
  assignNode("Kentucky", mapOffsetX + 695, mapOffsetY + 305, 25, 29);
  assignNode("West Virginia", mapOffsetX + 757, mapOffsetY + 273, 20, 30);
  assignNode("Virginia", mapOffsetX + 805, mapOffsetY + 282, 25, 31);
  assignNode("Wisconsin", mapOffsetX + 590, mapOffsetY + 150, 25, 32);
  assignNode("Illinois", mapOffsetX + 607, mapOffsetY + 250, 25, 33);
  assignNode("Indiana", mapOffsetX + 660, mapOffsetY + 255, 25, 34);
  assignNode("Michigan", mapOffsetX + 676, mapOffsetY + 180, 25, 35);
  assignNode("Ohio", mapOffsetX + 720, mapOffsetY + 240, 25, 36);
  assignNode("Pennsylvania", mapOffsetX + 800, mapOffsetY + 210, 25, 37);
  assignNode("New York", mapOffsetX + 837, mapOffsetY + 155, 25, 38);
  assignNode("Maine", mapOffsetX + 915, mapOffsetY + 75, 25, 39);
  assignNode("Vermont", mapOffsetX + 945, mapOffsetY + 120, 20, 40);
  assignNode("New Hampshire", mapOffsetX + 975, mapOffsetY + 120, 20, 41);
  assignNode("Massachusetts", mapOffsetX + 945, mapOffsetY + 150, 20, 42);
  assignNode("Connecticut", mapOffsetX + 945, mapOffsetY + 180, 20, 43);
  assignNode("Rhode Island", mapOffsetX + 975, mapOffsetY + 180, 20, 44);
  assignNode("New Jersey", mapOffsetX + 890, mapOffsetY + 215, 20, 45);
  assignNode("Maryland", mapOffsetX + 880, mapOffsetY + 255, 20, 46);
  assignNode("Delaware", mapOffsetX + 910, mapOffsetY + 255, 20, 47);
  assignNode("Alaska", mapOffsetX + 100, mapOffsetY + 510, 25, 48);
  assignNode("Hawaii", mapOffsetX + 260, mapOffsetY + 540, 25, 49);
}

//***************************************************************
