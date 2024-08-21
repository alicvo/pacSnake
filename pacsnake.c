#include <stdio.h>
#include <conio.h>
#include <stdlib.h>
#include <windows.h>
#include <stdbool.h>

#define WIDTH 30
#define HEIGHT 20
#define MAX_BODY_LENGTH (WIDTH * HEIGHT)

int snakeX, snakeY;
int foodX, foodY;
int score = 0;
int gameOverFlag = 0;

int isGhostVulnerable = 0;
int vulnerabilityDuration = 5000;
int snakeMoveDelay = 250;

char pacmanMap[HEIGHT][WIDTH] = {
        "##########################",
        "#                       ##",
        "# # # ### ### ### ### # ##",
        "# # # ###     ### ### # ##",
        "# # #     #####         ##",
        "# # # # # #   # # # # # ##",
        "# # # # # ## ## # # # # ##",
        "#                       ##",
        "# # ### # # # # # ### # ##",
        "# # ### # # # # # ### # ##",
        "#                       ##",
        "# ## # ########### #######",
        "# ## #                   #",
        "# ## # # ########### # # #",
        "# ## # # #           # # #",
        "# ## # # # ########### # #",
        "#                        #",
        "##########################",
    };

enum Direction { UP, DOWN, LEFT, RIGHT };
enum Direction direction;

struct {
    int x, y;
} body[MAX_BODY_LENGTH];

struct ghost {
    int x, y;
} ghost1, ghost2, ghost3;

int bodyLength = 0;

int main() {
    setupGame();

    while (!gameOverFlag) {
        draw();
        getInput();
        moveGhost(&ghost1, snakeX, snakeY);
        moveGhost(&ghost2, snakeX, snakeY);
        moveGhost(&ghost3, snakeX, snakeY);
        update();
        if (isGameOver()) {
            gameOver();
        }
        Sleep(250);
    }

}

void setupGame() {
    snakeX = WIDTH / 2;
    snakeY = HEIGHT / 2;
    foodX = rand() % WIDTH;
    foodY = rand() % HEIGHT;
    score = 0; 
    gameOverFlag = 0;
    direction = RIGHT;
    bodyLength = 0;
    ghost1.x = 11;
    ghost1.y = 5;
    ghost2.x = 12;
    ghost2.y = 5;
    ghost3.x = 13;
    ghost3.y = 5;
    isGhostVulnerable = 0;
}

void draw() {
    system("cls");

    for (int i = 0; i < HEIGHT; i++) {
        for (int j = 0; j < WIDTH; j++) {
            char currentChar = pacmanMap[i][j];
            
            if (i == ghost1.y && j == ghost1.x) {
                putchar('G');

            }
            else if (i == ghost2.y && j == ghost2.x) {
                putchar('G');

            }
            else if (i == ghost3.y && j == ghost3.x) {
                putchar('G');

            }
            else if (i == snakeY && j == snakeX) {
                putchar('S');

            }
            else if (i == foodY && j == foodX) {
                if(currentChar == '#'){
                    foodX = rand() % (WIDTH - 6) + 1;
                    foodY = rand() % (HEIGHT - 3) + 1;
                }
                if (i == foodY && j == foodX){
                    putchar('F');
                }
            } 
            else {
                int isBodySegment = 0;
                for (int k = 0; k < bodyLength; k++) {
                    if (i == body[k].y && j == body[k].x) {
                        putchar('o');
                        isBodySegment = 1;
                        break; 
                    }
                }
                if (!isBodySegment) {
                    putchar(currentChar);
                }
            }

            if(currentChar == '#')
            {
                if(snakeX == j && snakeY == i)
                {
                    gameOver();
                }
            }
        }
        putchar('\n');
    }

    printf("Score: %d\n", score);
}

void getInput() {
    if (_kbhit()) {
        char input = _getch();
        switch (input) {
            case 'w':
                if (direction != DOWN)
                    direction = UP;
                break;
            case 's':
                if (direction != UP)
                    direction = DOWN;
                break;
            case 'a':
                if (direction != RIGHT)
                    direction = LEFT;
                break;
            case 'd':
                if (direction != LEFT)
                    direction = RIGHT;
                break;
        }
    }
}

void update() {

    for (int i = bodyLength - 1; i > 0; i--) {
        body[i] = body[i - 1];
    }
    if (bodyLength > 0) {
        body[0].x = snakeX;
        body[0].y = snakeY;
    }

    switch (direction) {
        case UP:
            snakeY--;
            break;
        case DOWN:
            snakeY++;
            break;
        case LEFT:
            snakeX--;
            break;
        case RIGHT:
            snakeX++;
            break;
    }

    if (snakeX == foodX && snakeY == foodY) {
        score++;
        isGhostVulnerable = 1;
        foodX = rand() % (WIDTH - 6) + 1;
        foodY = rand() % (HEIGHT - 3) + 1;
        if (bodyLength < MAX_BODY_LENGTH) {
            bodyLength++;
        }
        if (isGhostVulnerable) {
        vulnerabilityDuration -= snakeMoveDelay;
        if (vulnerabilityDuration <= 0) {
            isGhostVulnerable = 0;
            vulnerabilityDuration = 5000;
        }
        }
    }

    if(isGhostVulnerable){
        if(snakeX == ghost1.x && snakeY == ghost1.y){
            ghost1.x = 11;
            ghost1.y = 5;
        }
        else if(snakeX == ghost2.x && snakeY == ghost2.y){
            ghost2.x = 12;
            ghost2.y = 5;
        }
        else if(snakeX == ghost3.x && snakeY == ghost3.y){
            ghost3.x = 13;
            ghost3.y = 5;
        }
    }
}

int isGameOver() {

    if (snakeX < 0 || snakeX > WIDTH - 6|| snakeY < 0 || snakeY > HEIGHT - 3) {
        return 1;
    }
    for (int i = 0; i < bodyLength; i++) {
        if (snakeX == body[i].x && snakeY == body[i].y) {
            return 1;
        }
    }
    if(!isGhostVulnerable){
        if (snakeX == ghost1.x && snakeY == ghost1.y)
        {
            return 1;
        }
        else if (snakeX == ghost2.x && snakeY == ghost2.y)
        {
            return 1;
        }
        else if (snakeX == ghost3.x && snakeY == ghost3.y)
        {
            return 1;
        }
    }
    return 0;
}

void gameOver() {
    char input;

    system("cls");
    printf("Game Over!\n");
    printf("Your Score: %d\n", score);
    
    printf("Enter P to play again\n");
    printf("Enter X to quit\n");
    scanf("%c", &input);
    if(input == 'p' || input == 'P'){
        gameOverFlag = 0;
        setupGame();
    }
    else if(input == 'x' || input == 'X'){
        gameOverFlag = 1;
    }
}

bool isValidMove(int x, int y) {
    if (x >= 0 && x < WIDTH && y >= 0 && y < HEIGHT && pacmanMap[y][x] != '#') {
        return true;
    }
    return false;
}

void moveGhost(struct ghost *ghost, int targetX, int targetY) {
    int dx[] = {0, 0, -1, 1};   //possible horizontal movement directions
    int dy[] = {-1, 1, 0, 0};   //possible vertical movement directions

    if(isGhostVulnerable)
    {
         int awayDirection = rand() % 4;

        int nx = ghost->x + dx[awayDirection];
        int ny = ghost->y + dy[awayDirection];

        if (isValidMove(nx, ny)) {
            ghost->x = nx;
            ghost->y = ny;
        }
    }
    else{
        for (int i = 0; i < 4; i++) {
            int nx = ghost->x + dx[i];  //next potential horizontal position
            int ny = ghost->y + dy[i];  //next potential vertical positio

            if (isValidMove(nx, ny)) {  //checks if next move is not a wall or out of bounds
                int distance = abs(nx - targetX) + abs(ny - targetY);   //manhattan distance

                int currentDistance = abs(ghost->x - targetX) + abs(ghost->y - targetY); 

                if (distance < currentDistance) {   //if the potential move gets the ghost closer to the target
                    ghost->x = nx;  
                    ghost->y = ny;
                    return; //exit when valid move is found
                }
            }
        }
    }
}
