Shader "Custom/moeda"
{
    Properties
    {
        _ColorUp ("ColorUp", Color) = (1,0,0,1)
        _ColorDown ("ColorDown", Color) = (1,0,1,1)
        _ColorRight ("ColorRight", Color) = (0,0,1,1)
        _ColorLeft ("ColorLeft", Color) = (0,1,1,1)
        _ColorFront ("ColorFront", Color) = (0,1,0,1)
        _ColorBack ("ColorBack", Color) = (1,1,0,1)
        _MainTex ("Albedo", 2D) = "white" {}
        _CoinTex ("CoinText", 2D) = "white" {}
        _coinPosition("coinPosition", Range (-1, 5)) = 1

        [Toggle(USE_TEXTURE)] _UseTextureEmptyUp("Remove Up", Float) = 0
        [Toggle(USE_TEXTURE)] _UseTextureEmptyFrontRight("Remove Front and Right", Float) = 0 
        [Toggle(USE_TEXTURE)] _UseTextureEmptyDownLeft("Remove Left and Down", Float) = 0
        [Toggle(USE_TEXTURE)] _UseTextureEmptyBack("Remove Back", Float) = 0 
        [Toggle(USE_TEXTURE)] _UseTextureCoin("rotate 180º coin", Float) = 0 
        [Toggle(USE_TEXTURE)] _UseTextureCoinRotate("move coin", Float) = 0

    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Cull Front

        CGPROGRAM

        #pragma surface surf Lambert alpha vertex:vert
        #pragma shader_feature USE_TEXTURE

        fixed4  _ColorUp;
        fixed4 _ColorDown;
        fixed4 _ColorRight;
        fixed4 _ColorLeft;
        fixed4 _ColorFront;
        fixed4 _ColorBack;
        sampler2D _CoinTex;

        float _UseTextureCoin;
        float _UseTextureCoinRotate;

        float _coinPosition;

        struct Input {
            float2 uv_CoinTex;
        };

        void vert (inout appdata_full v) {
            
            //v.vertex.x += v.normal.x * _coinPosition;
            if(v.normal.x <= 0.5)
               v.vertex.x += v.normal.x * _coinPosition;                
        }

        void surf(Input IN, inout SurfaceOutput o){
            
            float3 _up = float3(0, 1, 0);
            float3 _down = float3(0, -1, 0);
            float3 _right = float3(0, 0, 1);
            float3 _left = float3(0, 0, -1);
            float3 _front = float3(1, 0, 0);
            float3 _back = float3(-1, 0, 0);

            fixed4 Coin = tex2D(_CoinTex, IN.uv_CoinTex);
            //o.Normal = -UnpackNormal(tex2D(_CoinTex, IN.uv_CoinTex));
            o.Alpha = Coin.a;

            float sinX = sin (5 * _Time);
            float cosX = cos (5 * _Time);
            float2x2 rotation = float2x2(cosX, -sinX, sinX, cosX);
            float2 rotationDirection = mul(o.Normal, rotation);

            float pi = 3.14159;
            float rot180 = cos (pi);
            

            if ((o.Normal.x <= _up.x + 0.3 && o.Normal.x >= _up.x - 0.3) && /*o.Normal.y >= 0.5*/ 
                (o.Normal.y >= _up.y - 0.5 && o.Normal.y <= _up.y) && 
                (o.Normal.z <= _up.z + 0.3 && o.Normal.z >= _up.z - 0.3)){
                
                    o.Albedo = Coin * _ColorUp;
            }
            else if ((o.Normal.x <= _down.x + 0.3 && o.Normal.x >= _down.x - 0.3) && 
                    (o.Normal.y <= _down.y + 0.5 && o.Normal.y >= _down.y) && 
                    (o.Normal.z <= _down.z + 0.3 && o.Normal.z >= _down.z - 0.3)){
                    
                    if (_UseTextureCoinRotate == 0)
                        o.Albedo = Coin * _ColorDown;
                    else{
                        
                        /*float2 rotation = float2(sin((_Time.x * 2) + IN.uv_CoinTex.x) * 0.5, 
                        cos((_Time.x * 2 ) + IN.uv_CoinTex.x) * 0.5);*/

                        o.Albedo = tex2D(_CoinTex, IN.uv_CoinTex + rotationDirection)/*((rotation.xy - 0.5) + (rotation.y + 0.5))*/ * _ColorDown;
                    }
            }
            else if ((o.Normal.x <= _right.x + 0.3 && o.Normal.x >= _right.x - 0.3) && 
                    (o.Normal.y <= _right.y + 0.3 && o.Normal.y >= _right.y - 0.3) && 
                    (o.Normal.z >= _right.z - 0.5 && o.Normal.z <= _right.z)){
                
                    o.Albedo = Coin * _ColorRight; 
            }
            else if ((o.Normal.x <= _left.x + 0.3 && o.Normal.x >= _left.x - 0.3) && 
                    (o.Normal.y <= _left.y + 0.3 && o.Normal.y >= _left.y - 0.3) && 
                    (o.Normal.z <= _left.z + 0.5 && o.Normal.z >= _left.z)){
                    
                    if (_UseTextureCoin == 0)
                        o.Albedo = Coin * _ColorLeft;
                    else
                        o.Albedo = tex2D(_CoinTex, IN.uv_CoinTex * rot180) * _ColorLeft;
            }
            else if ((o.Normal.x >= _front.x - 0.5 && o.Normal.x <= _front.x) && 
                    (o.Normal.y <= _front.y + 0.3 && o.Normal.y >= _front.y - 0.3) && 
                    (o.Normal.z <= _front.z + 0.3 && o.Normal.z >= _front.z - 0.3)){
                
                    o.Albedo = Coin * _ColorFront;
            }
            else if ((o.Normal.x <= _back.x + 0.5 && o.Normal.z >= _back.x) &&
                    (o.Normal.y <= _back.y + 0.3 && o.Normal.y >= _front.y - 0.3) && 
                    (o.Normal.z <= _back.z + 0.3 && o.Normal.z >= _front.y - 0.3)){
                
                    o.Albedo = Coin * _ColorBack;
                    
                    
            }
        }

        ENDCG

        Cull Back

        CGPROGRAM

        #pragma surface surf Lambert
        #pragma shader_feature USE_TEXTURE

        struct Input
        {
            float2 uv_MainTex;
        };

        fixed4  _ColorUp;
        fixed4 _ColorDown;
        fixed4 _ColorRight;
        fixed4 _ColorLeft;
        fixed4 _ColorFront;
        fixed4 _ColorBack;
        sampler2D _MainTex;

        float _UseTextureEmptyUp;
        float _UseTextureEmptyFrontRight;
        float _UseTextureEmptyDownLeft;
        float _UseTextureEmptyBack;

        void surf (Input IN, inout SurfaceOutput o)
        {
            // o.Albedo = tex2D(_MainTex, IN.uv_MainTex);
            // o.Albedo = o.Normal;
            float3 _up = float3(0, 1, 0);
            float3 _down = float3(0, -1, 0);
            float3 _right = float3(0, 0, 1);
            float3 _left = float3(0, 0, -1);
            float3 _front = float3(1, 0, 0);
            float3 _back = float3(-1, 0, 0);
            float4 w = tex2D(_MainTex, IN.uv_MainTex);
            o.Alpha = w.a;

            if ((o.Normal.x <= _up.x + 0.3 && o.Normal.x >= _up.x - 0.3) && /*o.Normal.y >= 0.5*/ 
                (o.Normal.y >= _up.y - 0.5 && o.Normal.y <= _up.y) && 
                (o.Normal.z <= _up.z + 0.3 && o.Normal.z >= _up.z - 0.3)){
                    
                    if(_UseTextureEmptyUp == 0)
                        o.Albedo = _ColorUp;
                    else
                        discard;
            }
            else if ((o.Normal.x <= _down.x + 0.3 && o.Normal.x >= _down.x - 0.3) && 
                    (o.Normal.y <= _down.y + 0.5 && o.Normal.y >= _down.y) && 
                    (o.Normal.z <= _down.z + 0.3 && o.Normal.z >= _down.z - 0.3)){
                
                    if(_UseTextureEmptyDownLeft == 0)
                        o.Albedo = _ColorDown;
                    else
                        discard;
            }
            else if ((o.Normal.x <= _right.x + 0.3 && o.Normal.x >= _right.x - 0.3) && 
                    (o.Normal.y <= _right.y + 0.3 && o.Normal.y >= _right.y - 0.3) && 
                    (o.Normal.z >= _right.z - 0.5 && o.Normal.z <= _right.z)){
                    
                    if(_UseTextureEmptyFrontRight == 0)
                        o.Albedo = _ColorRight; 
                    else
                        discard;
            }
            else if ((o.Normal.x <= _left.x + 0.3 && o.Normal.x >= _left.x - 0.3) && 
                    (o.Normal.y <= _left.y + 0.3 && o.Normal.y >= _left.y - 0.3) && 
                    (o.Normal.z <= _left.z + 0.5 && o.Normal.z >= _left.z)){
                        
                    if(_UseTextureEmptyDownLeft == 0)
                        o.Albedo = _ColorLeft;
                    else
                        discard;
            }
            else if ((o.Normal.x >= _front.x - 0.5 && o.Normal.x <= _front.x) && 
                    (o.Normal.y <= _front.y + 0.3 && o.Normal.y >= _front.y - 0.3) && 
                    (o.Normal.z <= _front.z + 0.3 && o.Normal.z >= _front.z - 0.3)){
                    
                    if(_UseTextureEmptyFrontRight == 0)
                        o.Albedo = _ColorFront;
                    else
                        discard;
            }
            else if ((o.Normal.x <= _back.x + 0.5 && o.Normal.z >= _back.x) &&
                    (o.Normal.y <= _back.y + 0.3 && o.Normal.y >= _front.y - 0.3) && 
                    (o.Normal.z <= _back.z + 0.3 && o.Normal.z >= _front.y - 0.3)){
                
                    if(_UseTextureEmptyBack == 0)
                        o.Albedo = _ColorBack;
                    else
                        discard;
            }

            //gives us the normalized world space light
            // lightDir = normalize(o.Normal);

            // float dotp = dot(lightDir, o.Normal);

            // if (dotp >= 0.3)
            // {
            //     if (IN.uv_MainTex.x >= 0 && IN.uv_MainTex.y >= 0)
            //     {
            //         o.Albedo = tex2D(_MainTex, IN.uv_MainTex) * _Color;
            //     }
            //     else{
            //         discard;
            //     }
            // }
            // if (dotp < 0.3)
            // {
            //     if (IN.uv_MainTex.x >= 0 && IN.uv_MainTex.y >= 0)
            //     {
            //         o.Albedo = tex2D(_MainTex, IN.uv_MainTex) * _Color1;
            //     }
            //     else{
            //         discard;
            //     }
            // }

        }
        ENDCG
    }
    FallBack "Diffuse"
}