#version 410

layout(points) in;
layout(triangle_strip, max_vertices = 4) out;

uniform mat4 matrProj;

uniform int texnumero;

layout (std140) uniform varsUnif
{
    float tempsDeVieMax;       // temps de vie maximal (en secondes)
    float temps;               // le temps courant dans la simulation (en secondes)
    float dt;                  // intervalle entre chaque affichage (en secondes)
    float gravite;             // gravité utilisée dans le calcul de la position de la particule
    float pointsize;           // taille des points (en pixels)
};

in Attribs {
    vec4 couleur;
    float tempsDeVieRestant;
    float sens; // du vol (partie 3)
    float hauteur; // de la particule dans le repère du monde (partie 3)
} AttribsIn[];

out Attribs {
    vec4 couleur;
    vec2 texCoord;
    float tempsDeVieRestant;
} AttribsOut;

// la hauteur minimale en-dessous de laquelle les lutins ne tournent plus (partie 3)
const float hauteurInerte = 8.0;

void main()
{
    vec2 coins[4];
    coins[0] = vec2( -0.5,  0.5 );
    coins[1] = vec2( -0.5, -0.5 );
    coins[2] = vec2(  0.5,  0.5 );
    coins[3] = vec2(  0.5, -0.5 );

    for ( int i = 0 ; i < 4 ; ++i )
    {
        float fact = gl_in[0].gl_PointSize;

        vec2 decalage = coins[i]; // on positionne successivement aux quatre coins
        vec4 pos = vec4( gl_in[0].gl_Position.xy + fact * decalage, gl_in[0].gl_Position.zw );

        gl_Position = matrProj * pos;    // on termine la transformation débutée dans le nuanceur de sommets

        float A = (AttribsIn[0].tempsDeVieRestant / tempsDeVieMax);
        AttribsOut.couleur = AttribsIn[0].couleur;
        AttribsOut.couleur.a = A;

        AttribsOut.texCoord = coins[i] + vec2( 0.5, 0.5 ); // on utilise coins[] pour définir des coordonnées de texture
        AttribsOut.tempsDeVieRestant = AttribsIn[0].tempsDeVieRestant;

        if ( texnumero == 1 && AttribsIn[0].sens == -1) {
            AttribsOut.texCoord.s =  AttribsOut.texCoord.s * AttribsIn[0].sens; 
        }

        if ( texnumero == 2)
        {   
            if ( AttribsIn[0].hauteur >= hauteurInerte){ 
                float angle = 6.0 * AttribsIn[0].tempsDeVieRestant;
                mat2 matrix = mat2(cos(angle),-sin(angle),
                                   sin(angle), cos(angle));
                vec2 vec = vec2(0.5, 0.5);
                AttribsOut.texCoord.st = (AttribsOut.texCoord.st - vec) * matrix + vec;
            }
        }
        EmitVertex();
    }
}
