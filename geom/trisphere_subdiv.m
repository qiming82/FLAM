% TRISPHERE_SUBDIV      Recursive subdivision of unit sphere triangulation.
%
%    [V,F] = TRISPHERE_SUBDIV(N) produces a triangulation of the unit sphere
%    with vertices V and faces F of size at least N by recursively subdividing a
%    base triangulation of size 320. The vertices of triangle I are V(:,F(:,I)).
%    The number of triangles on output can be 320, 1280, 5120, 20480, etc.

function [V,F] = trisphere_subdiv(n)

  % initialize
  V = [-1.000000000000000   0.000000000000000                   0
       -0.956625793988502  -0.147620904422163  -0.251147683352745
       -0.956625793988502   0.147620904422163  -0.251147683352745
       -0.956625793988502   0.147620904422163  -0.251147683352745
       -0.951056516295154  -0.309016994374947                   0
       -0.951056516295154   0.309016994374948                   0
       -0.951056516295154   0.309016994374948                   0
       -0.947213595499958  -0.162459848116453   0.276393202250021
       -0.947213595499958   0.162459848116453   0.276393202250021
       -0.894427190999916   0.000000000000000  -0.447213595499958
       -0.894427190999916   0.000000000000000  -0.447213595499958
       -0.861803398874989  -0.425325404176020  -0.276393202250021
       -0.861803398874989   0.425325404176020  -0.276393202250021
       -0.860695915143550  -0.442862713266489   0.251147683352745
       -0.860695915143550   0.442862713266490   0.251147683352745
       -0.860695915143550   0.442862713266490   0.251147683352745
       -0.850650808352040   0.000000000000000   0.525731112119134
       -0.831051952312130  -0.238855640805059  -0.502295366705489
       -0.831051952312130   0.238855640805060  -0.502295366705489
       -0.812730975721074  -0.295241808844326   0.502295366705489
       -0.812730975721074  -0.295241808844326   0.502295366705489
       -0.812730975721074   0.295241808844326   0.502295366705489
       -0.809016994374948  -0.587785252292473                   0
       -0.809016994374947   0.587785252292473                   0
       -0.753443050058234   0.000000000000000  -0.657513171213282
       -0.753443050058234   0.000000000000000  -0.657513171213281
       -0.723606797749979  -0.525731112119133   0.447213595499958
       -0.723606797749979   0.525731112119134   0.447213595499958
       -0.688190960235587  -0.500000000000000  -0.525731112119134
       -0.688190960235587   0.500000000000000  -0.525731112119134
       -0.687157134044702  -0.681718354071549   0.251147683352745
       -0.687157134044701   0.681718354071549   0.251147683352745
       -0.670820393249937  -0.688190960235587  -0.276393202250021
       -0.670820393249937  -0.162459848116453   0.723606797749979
       -0.670820393249937   0.162459848116453   0.723606797749979
       -0.670820393249937   0.688190960235587  -0.276393202250021
       -0.638196601125011  -0.262865556059567  -0.723606797749979
       -0.638196601125011   0.262865556059567  -0.723606797749979
       -0.609548231790805  -0.442862713266489   0.657513171213282
       -0.609548231790805   0.442862713266490   0.657513171213282
       -0.587785252292473  -0.809016994374947                   0
       -0.587785252292473  -0.809016994374947                   0
       -0.587785252292473   0.809016994374948                   0
       -0.531939329536909  -0.681718354071549   0.502295366705489
       -0.531939329536909   0.681718354071549   0.502295366705489
       -0.525731112119134   0.000000000000000  -0.850650808352040
       -0.525731112119134   0.000000000000000  -0.850650808352040
       -0.483974390114433  -0.716566922415179  -0.502295366705489
       -0.483974390114433   0.716566922415179  -0.502295366705489
       -0.447213595499958  -0.850650808352040   0.276393202250021
       -0.447213595499958  -0.525731112119133  -0.723606797749979
       -0.447213595499958   0.000000000000000   0.894427190999916
       -0.447213595499958   0.525731112119134  -0.723606797749979
       -0.447213595499958   0.850650808352040   0.276393202250021
       -0.436009450691957  -0.864187826837342  -0.251147683352745
       -0.436009450691957  -0.864187826837342  -0.251147683352745
       -0.436009450691957   0.864187826837342  -0.251147683352745
       -0.425325404176020  -0.309016994374947   0.850650808352040
       -0.425325404176020   0.309016994374948   0.850650808352040
       -0.361803398874990  -0.262865556059567  -0.894427190999916
       -0.361803398874990  -0.587785252292473   0.723606797749979
       -0.361803398874990   0.262865556059567  -0.894427190999916
       -0.361803398874989   0.587785252292473   0.723606797749979
       -0.309016994374948  -0.951056516295153                   0
       -0.309016994374947   0.951056516295154                   0
       -0.276393202250021  -0.850650808352040  -0.447213595499958
       -0.276393202250021   0.850650808352040  -0.447213595499958
       -0.262865556059567  -0.809016994374947   0.525731112119134
       -0.262865556059567   0.809016994374947   0.525731112119134
       -0.251147683352745   0.000000000000000  -0.967948780228866
       -0.251147683352745   0.000000000000000  -0.967948780228866
       -0.232826706761689  -0.716566922415179  -0.657513171213282
       -0.232826706761688  -0.716566922415179  -0.657513171213282
       -0.232826706761688   0.716566922415179  -0.657513171213281
       -0.232826706761688   0.716566922415179  -0.657513171213281
       -0.203182743930269  -0.147620904422163   0.967948780228866
       -0.203182743930268   0.147620904422163   0.967948780228866
       -0.203182743930268   0.147620904422163   0.967948780228866
       -0.162459848116453  -0.500000000000000  -0.850650808352040
       -0.162459848116453   0.500000000000000  -0.850650808352040
       -0.162459848116453   0.500000000000000  -0.850650808352040
       -0.155217804507792  -0.955422563220238  -0.251147683352745
       -0.155217804507792   0.955422563220238  -0.251147683352745
       -0.138196601125011  -0.951056516295154   0.276393202250021
       -0.138196601125011  -0.425325404176020   0.894427190999916
       -0.138196601125011   0.425325404176020   0.894427190999916
       -0.138196601125010   0.951056516295154   0.276393202250021
       -0.077608902253896  -0.238855640805060  -0.967948780228866
       -0.077608902253896  -0.238855640805060  -0.967948780228866
       -0.077608902253896   0.238855640805060  -0.967948780228866
       -0.052786404500042  -0.688190960235587   0.723606797749979
       -0.052786404500042   0.688190960235587   0.723606797749979
       -0.029643962831420  -0.864187826837342  -0.502295366705489
       -0.029643962831420  -0.864187826837342  -0.502295366705489
       -0.029643962831420   0.864187826837342  -0.502295366705489
       -0.029643962831420   0.864187826837342  -0.502295366705489
       -0.000000000000000  -1.000000000000000                   0
                        0                   0  -1.000000000000000
                        0                   0   1.000000000000000
        0.000000000000000   1.000000000000000                   0
        0.029643962831420  -0.864187826837342   0.502295366705489
        0.029643962831420  -0.864187826837342   0.502295366705489
        0.029643962831420   0.864187826837342   0.502295366705489
        0.029643962831420   0.864187826837342   0.502295366705489
        0.052786404500042  -0.688190960235587  -0.723606797749979
        0.052786404500042   0.688190960235587  -0.723606797749979
        0.077608902253896  -0.238855640805060   0.967948780228866
        0.077608902253896   0.238855640805060   0.967948780228866
        0.077608902253896   0.238855640805060   0.967948780228866
        0.138196601125010  -0.951056516295154  -0.276393202250021
        0.138196601125010  -0.425325404176020  -0.894427190999916
        0.138196601125011   0.425325404176020  -0.894427190999916
        0.138196601125011   0.951056516295153  -0.276393202250021
        0.155217804507792  -0.955422563220238   0.251147683352745
        0.155217804507792   0.955422563220238   0.251147683352745
        0.155217804507792   0.955422563220238   0.251147683352745
        0.162459848116453  -0.500000000000000   0.850650808352040
        0.162459848116453  -0.500000000000000   0.850650808352040
        0.162459848116453   0.500000000000000   0.850650808352040
        0.162459848116453   0.500000000000000   0.850650808352040
        0.203182743930268  -0.147620904422163  -0.967948780228866
        0.203182743930269   0.147620904422163  -0.967948780228866
        0.232826706761688  -0.716566922415179   0.657513171213281
        0.232826706761688  -0.716566922415179   0.657513171213281
        0.232826706761689   0.716566922415179   0.657513171213282
        0.232826706761689   0.716566922415179   0.657513171213282
        0.251147683352745  -0.000000000000000   0.967948780228866
        0.251147683352745                   0   0.967948780228866
        0.262865556059567  -0.809016994374947  -0.525731112119134
        0.262865556059567   0.809016994374947  -0.525731112119134
        0.276393202250021  -0.850650808352040   0.447213595499958
        0.276393202250021   0.850650808352040   0.447213595499958
        0.309016994374947  -0.951056516295154                   0
        0.309016994374948   0.951056516295154                   0
        0.361803398874989  -0.587785252292473  -0.723606797749979
        0.361803398874989  -0.262865556059567   0.894427190999916
        0.361803398874990   0.262865556059567   0.894427190999916
        0.361803398874990   0.587785252292473  -0.723606797749979
        0.425325404176020  -0.309016994374948  -0.850650808352040
        0.425325404176020   0.309016994374947  -0.850650808352040
        0.425325404176020   0.309016994374947  -0.850650808352040
        0.436009450691957  -0.864187826837342   0.251147683352745
        0.436009450691957   0.864187826837342   0.251147683352745
        0.447213595499958  -0.850650808352040  -0.276393202250021
        0.447213595499958  -0.525731112119134   0.723606797749979
        0.447213595499958  -0.000000000000000  -0.894427190999916
        0.447213595499958   0.525731112119133   0.723606797749979
        0.447213595499958   0.850650808352040  -0.276393202250021
        0.483974390114433  -0.716566922415179   0.502295366705489
        0.483974390114433   0.716566922415179   0.502295366705489
        0.525731112119134  -0.000000000000000   0.850650808352040
        0.525731112119134  -0.000000000000000   0.850650808352040
        0.531939329536909  -0.681718354071549  -0.502295366705489
        0.531939329536909   0.681718354071549  -0.502295366705489
        0.587785252292473  -0.809016994374948                   0
        0.587785252292473  -0.809016994374948                   0
        0.587785252292473   0.809016994374947                   0
        0.609548231790805  -0.442862713266490  -0.657513171213282
        0.609548231790805   0.442862713266489  -0.657513171213282
        0.638196601125010  -0.262865556059567   0.723606797749979
        0.638196601125011   0.262865556059567   0.723606797749979
        0.670820393249937  -0.688190960235587   0.276393202250021
        0.670820393249937  -0.162459848116453  -0.723606797749979
        0.670820393249937   0.162459848116453  -0.723606797749979
        0.670820393249937   0.688190960235587   0.276393202250021
        0.687157134044701  -0.681718354071549  -0.251147683352745
        0.687157134044702   0.681718354071549  -0.251147683352745
        0.688190960235587  -0.500000000000000   0.525731112119134
        0.688190960235587   0.500000000000000   0.525731112119134
        0.723606797749979  -0.525731112119134  -0.447213595499958
        0.723606797749979   0.525731112119133  -0.447213595499958
        0.753443050058234  -0.000000000000000   0.657513171213281
        0.753443050058234  -0.000000000000000   0.657513171213281
        0.809016994374947  -0.587785252292473                   0
        0.809016994374948   0.587785252292473                   0
        0.812730975721074  -0.295241808844326  -0.502295366705489
        0.812730975721074   0.295241808844326  -0.502295366705489
        0.812730975721074   0.295241808844326  -0.502295366705489
        0.831051952312130  -0.238855640805060   0.502295366705489
        0.831051952312130   0.238855640805059   0.502295366705489
        0.850650808352040  -0.000000000000000  -0.525731112119134
        0.860695915143550  -0.442862713266490  -0.251147683352745
        0.860695915143550   0.442862713266489  -0.251147683352745
        0.860695915143550   0.442862713266489  -0.251147683352745
        0.861803398874989  -0.425325404176020   0.276393202250021
        0.861803398874989   0.425325404176020   0.276393202250021
        0.894427190999916  -0.000000000000000   0.447213595499958
        0.894427190999916  -0.000000000000000   0.447213595499958
        0.947213595499958  -0.162459848116453  -0.276393202250021
        0.947213595499958   0.162459848116453  -0.276393202250021
        0.951056516295154  -0.309016994374948                   0
        0.951056516295154   0.309016994374947                   0
        0.956625793988502  -0.147620904422163   0.251147683352745
        0.956625793988502   0.147620904422163   0.251147683352745
        0.956625793988502   0.147620904422163   0.251147683352745
        1.000000000000000  -0.000000000000000                   0];
  F = [132   104   126
        92   126   104
       104    69    92
        63    92    69
        69    45    63
        40    63    45
        45    28    40
       126    92   119
        86   119    92
        92    63    86
        59    86    63
        63    40    59
       119    86   109
        77   109    86
        86    59    77
       109    77    99
        28    22    40
        35    40    22
        22    17    35
        34    35    17
        17    20    34
        39    34    20
        20    27    39
        40    35    59
        52    59    35
        35    34    52
        58    52    34
        34    39    58
        59    52    78
        76    78    52
        52    58    76
        78    76    99
        27    44    39
        61    39    44
        44    68    61
        91    61    68
        68   101    91
       123    91   101
       101   131   123
        39    61    58
        85    58    61
        61    91    85
       118    85    91
        91   123   118
        58    85    76
       107    76    85
        85   118   107
        76   107    99
       131   149   124
       145   124   149
       149   168   145
       160   145   168
       168   179   160
       172   160   179
       179   187   172
       124   145   117
       136   117   145
       145   160   136
       151   136   160
       160   172   151
       117   136   107
       128   107   136
       136   151   128
       107   128    99
       188   180   173
       161   173   180
       180   169   161
       147   161   169
       169   150   147
       125   147   150
       150   132   125
       173   161   152
       137   152   161
       161   147   137
       120   137   147
       147   125   120
       152   137   127
       108   127   137
       137   120   108
       127   108    99
       170   153   158
       135   158   153
       153   129   135
       105   135   129
       129    94   105
        73   105    94
        94    66    73
       158   135   139
       111   139   135
       135   105   111
        79   111   105
       105    73    79
       139   111   121
        88   121   111
       111    79    88
       121    88    98
       171   177   159
       164   159   177
       177   181   164
       163   164   181
       181   176   163
       158   163   176
       176   170   158
       159   164   141
       146   141   164
       164   163   146
       139   146   163
       163   158   139
       141   146   122
       121   122   146
       146   139   121
       122   121    98
        67    95    74
       106    74    95
        95   130   106
       138   106   130
       130   154   138
       159   138   154
       154   171   159
        74   106    80
       112    80   106
       106   138   112
       140   112   138
       138   159   140
        80   112    90
       122    90   112
       112   140   122
        90   122    98
        10    19    26
        38    26    19
        19    30    38
        53    38    30
        30    49    53
        75    53    49
        49    67    75
        26    38    47
        62    47    38
        38    53    62
        81    62    53
        53    75    81
        47    62    70
        90    70    62
        62    81    90
        70    90    98
        66    48    72
        51    72    48
        48    29    51
        37    51    29
        29    18    37
        25    37    18
        18    11    25
        72    51    79
        60    79    51
        51    37    60
        46    60    37
        37    25    46
        79    60    89
        71    89    60
        60    46    71
        89    71    98
        28    45    32
        54    32    45
        45    69    54
        87    54    69
        69   103    87
       116    87   103
       103   132   116
        32    54    43
        65    43    54
        54    87    65
       100    65    87
        87   116   100
        43    65    57
        83    57    65
        65   100    83
        57    83    67
        27    21    14
         8    14    21
        21    17     8
         9     8    17
        17    22     9
        16     9    22
        22    28    16
        14     8     5
         1     5     8
         8     9     1
         6     1     9
         9    16     6
         5     1     2
         3     2     1
         1     6     3
         2     3    11
       131   102   114
        84   114   102
       102    68    84
        50    84    68
        68    44    50
        31    50    44
        44    27    31
       114    84    97
        64    97    84
        84    50    64
        42    64    50
        50    31    42
        97    64    82
        56    82    64
        64    42    56
        82    56    66
       188   179   193
       185   193   179
       179   168   185
       162   185   168
       168   149   162
       142   162   149
       149   131   142
       193   185   191
       174   191   185
       185   162   174
       155   174   162
       162   142   155
       191   174   182
       166   182   174
       174   155   166
       182   166   170
       132   150   143
       165   143   150
       150   169   165
       186   165   169
       169   180   186
       194   186   180
       180   187   194
       143   165   157
       175   157   165
       165   186   175
       192   175   186
       186   194   192
       157   175   167
       184   167   175
       175   192   184
       167   184   171
       170   176   182
       189   182   176
       176   181   189
       190   189   181
       181   178   190
       183   190   178
       178   171   183
       182   189   191
       196   191   189
       189   190   196
       192   196   190
       190   183   192
       191   196   193
       195   193   196
       196   192   195
       193   195   187
       171   154   167
       148   167   154
       154   130   148
       113   148   130
       130    96   113
        83   113    96
        96    67    83
       167   148   157
       134   157   148
       148   113   134
       100   134   113
       113    83   100
       157   134   143
       115   143   134
       134   100   115
       143   115   132
        67    49    57
        36    57    49
        49    30    36
        13    36    30
        30    19    13
         4    13    19
        19    11     4
        57    36    43
        24    43    36
        36    13    24
         7    24    13
        13     4     7
        43    24    32
        15    32    24
        24     7    15
        32    15    28
        10    18     2
        12     2    18
        18    29    12
        33    12    29
        29    48    33
        55    33    48
        48    66    55
         2    12     5
        23     5    12
        12    33    23
        41    23    33
        33    55    41
         5    23    14
        31    14    23
        23    41    31
        14    31    27
        66    93    82
       110    82    93
        93   129   110
       144   110   129
       129   153   144
       166   144   153
       153   170   166
        82   110    97
       133    97   110
       110   144   133
       156   133   144
       144   166   156
        97   133   114
       142   114   133
       133   156   142
       114   142   131];
  m = size(F,1);

  % recursively subdivide and project
  while m < n
    M = 0.5*[V(F(:,1),:) + V(F(:,2),:)
             V(F(:,1),:) + V(F(:,3),:)
             V(F(:,2),:) + V(F(:,3),:)];
    M = M./(sqrt(sum(M.^2,2))*ones(1,3));
    [M,~,I] = unique(M,'rows');
    nv = size(V,1);
    F12 = nv + I(    1:  m);
    F13 = nv + I(  m+1:2*m);
    F23 = nv + I(2*m+1:3*m);
    V = [V; M];
    F = [F(:,1)  F12    F13
          F12   F(:,2)  F23
          F13    F23   F(:,3)
          F12    F23    F13];
    m = size(F,1);
  end

  % rotate outputs
  V = V';
  F = F';
end