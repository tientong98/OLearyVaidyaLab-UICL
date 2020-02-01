#!/bin/bash

source ~/sourcefiles/fsl_source.sh
source ~/sourcefiles/afni_source.sh

bolddir=/oleary/functional/UICL/BIDS/derivatives/subject_level_glm/rest

# reorient roi masks from RPI to LPI

3dresample -master /oleary/functional/UICL/BIDS/derivatives/subject_level_glm/rest/sub-3004/ses-60642114/res4d_normandscaled.nii.gz -prefix /oleary/atlas/greeneatlas/greene300LPI.nii.gz -input /oleary/atlas/greeneatlas/greene300.nii.gz

sub=(3003 3004 3005 3006 3009 3011 3013 3016 3017 3018 3021 3022 3023 3024 3025 3026 3027 3029 3030 3031 3032 3034 3036 3037 3039 3040 3041 3042 3043 3044 3045 3046 3050 3051 3052 3055 3056 3057 3058 3059 3060 3061 3062 3063 3066 3067 3068 3069 3070 3071 3072 3073 3074 3075 3076 3077 3078 3079 3080 3081 3082 3083 3084 3085 3086 3087 3089 3091 3093 3094 3095 3096 3097 3098 3099 3100 3101 3102 3103 3104 3106 3107 3108 3110 3111 3112 3113 3114 3116 3117 3118 3120 3123 3125 3126 3127 3128 3129 3130 3132 3133 3134 3136 3137 3138 3139 3140 3141 3142 3144 3145 3148 3149 3150 3151 3152 3153 3155 3157 3158 3160 3161 3163 3164 3165 3166 3167 3168 3169 3171 3172 3173 3175 3176 3177 3181 3182 3183 3184 3185 3186 3187 3188 3189 3192 3193 3195 3197 3198 3199 3200 3201 3202 3203 3204 3205 3206 3207 3208 3209 4101 5000 5001 5002 5003 5004 5006 5007 5008 5009 5010 5011 5012 5014 5015 5016 5017 5018 5020 5022 5024 5025 5026 5027 5028 5029 5030 5031 5032 5034 5035 5036 5037 5038 5039 5040 5041 5043 5044 5047 5048 5050 5051 5052 5054 5055 5059 5061 5062 5064 5065 5066 5067 5068 5069 5070 5072 5073 5074 5075 5076)

ses=(60844114 60642114 60730114 61218714 60946214 60913814 61230414 61319014 61449114 61434514 61032114 61145414 61432614 61722814 61549914 61521914 61535914 61620714 61750814 61721914 61708114 61822714 61763914 63926214 62369814 64069714 64182514 64184914 64125314 64272114 64066514 64243014 64559714 64444714 64442614 64342014 64558514 64459014 64744514 64977014 64645914 64572314 64747014 65047514 64975114 64990514 64932914 65147714 65060914 65076014 60223115 65062714 60641315 65248914 60093215 60527515 60498815 60628415 60483615 60512015 60597115 60595615 60526115 60700715 60540315 60585615 60926915 61045415 60801315 60712915 60743615 60900715 60930815 61027015 61031615 61348315 60988915 61032515 61231215 61290115 61017415 61333815 61230315 61491515 61001215 61346915 61636915 61388015 61435015 61535415 61635515 61620715 61705915 61693915 61895515 61835415 61822415 61907115 62137915 63764115 63551315 63937815 63954715 63853815 63739515 63710315 63940415 64040415 63825815 63969115 64012615 64128115 64153315 64154215 64415115 63868015 64069515 64024015 64356315 64416115 64573115 64743515 64457015 64917015 64632215 64470115 64875115 65050315 64859015 64948715 64731715 64861115 65061515 60511116 60585716 60667716 60527716 60683216 60727216 60815816 60700916 60900316 60898816 61029516 61101116 61304416 61636716 61680116 61507016 61491816 61835516 61632616 61693416 61722516 61708616 61823616 61837616 61924316 61936216 61807916 64874513 63969514 64024314 64157414 64427014 64343414 64670814 64557614 64657514 64544814 64672514 64746014 64628814 64661014 64686414 64974114 65074914 60439215 60643215 60842315 61331615 61144615 61101215 60885915 61102415 61044415 60927915 61216515 61303315 61447415 61518315 61736215 61723415 61807915 63537915 61851815 63750515 61794415 63939515 64053115 64227215 64357315 64443515 64340315 64224815 65059715 64617215 64831215 64659615 64934915 64958315 60094116 60423316 60830516 61190016 61014516 61088816 61204616 61405416 61319516 61780216)

for n in 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 96 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 120 121 122 123 124 125 126 127 128 129 130 131 132 133 134 135 136 137 138 139 140 141 142 143 144 145 146 147 148 149 150 151 152 153 154 155 156 157 158 159 160 161 162 163 164 165 166 167 168 169 170 171 172 173 174 175 176 177 178 179 180 181 182 183 184 185 186 187 188 189 190 191 192 193 194 195 196 197 198 199 200 201 202 203 204 205 206 207 208 209 210 211 212 213 214 215 216 217 218 219 220 ; do


#for n in 0 1 ; do

# get time series from ROIs
# cite Taylor PA, Saad ZS (2013).  FATCAT: (An Efficient) Functional And Tractographic Connectivity Analysis Toolbox. Brain Connectivity 3(5):523-535.

3dNetCorr \
 -inset $bolddir/sub-${sub[$n]}/ses-${ses[$n]}/res4d_normandscaled.nii.gz \
 -in_rois /oleary/atlas/greeneatlas/greene300LPI.nii.gz \
 -mask $bolddir/sub-${sub[$n]}/ses-${ses[$n]}/mask.nii.gz -fish_z \
 -prefix $bolddir/sub-${sub[$n]}/ses-${ses[$n]}/sub-${sub[$n]}_ses-${ses[$n]}_extendedPower         
  
done

