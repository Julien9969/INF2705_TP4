#version 410

uniform sampler2D leLutin;
uniform int texnumero;

in Attribs {
    vec4 couleur;
    vec2 texCoord;
    float tempsDeVieRestant;
} AttribsIn;

out vec4 FragColor;

void main( void )
{
    FragColor = AttribsIn.couleur;
    
    if ( texnumero != 0 )
    {
        vec2 coord = AttribsIn.texCoord;
        if (texnumero == 1) {
            const float nlutins = 16.0;
            int num = int ( mod ( 18.0 * AttribsIn.tempsDeVieRestant , nlutins ) ); 
            coord.s = ( coord.s + num ) / nlutins ;
        }

        vec4 texColor = texture(leLutin, coord);
        if( texColor.a < 0.1) discard;
        FragColor = vec4(mix( AttribsIn.couleur.rgb, texColor.rgb, 0.6), AttribsIn.couleur.a);
    }
}
