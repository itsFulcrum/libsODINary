/*
 Copyright 2017-2022 Google Inc.

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
*/

/*

VERSION HISTORY

  1.0   (2018-03-27) Initial public release

*/

// clang-format off
/*!

 @file spirv_reflect.h

*/
package spirv_reflect

import "core:c"

/// ================================
// spirv.h

SpvDim :: enum u32 {
  Dim1D = 0,
  Dim2D = 1,
  Dim3D = 2,
  DimCube = 3,
  DimRect = 4,
  DimBuffer = 5,
  DimSubpassData = 6,
  DimTileImageDataEXT = 4173,
  DimMax = 0x7fffffff,
}

SpvImageFormat :: enum u32 {
  Unknown = 0,
  Rgba32f = 1,
  Rgba16f = 2,
  R32f = 3,
  Rgba8 = 4,
  Rgba8Snorm = 5,
  Rg32f = 6,
  Rg16f = 7,
  R11fG11fB10f = 8,
  R16f = 9,
  Rgba16 = 10,
  Rgb10A2 = 11,
  Rg16 = 12,
  Rg8 = 13,
  R16 = 14,
  R8 = 15,
  Rgba16Snorm = 16,
  Rg16Snorm = 17,
  Rg8Snorm = 18,
  R16Snorm = 19,
  R8Snorm = 20,
  Rgba32i = 21,
  Rgba16i = 22,
  Rgba8i = 23,
  R32i = 24,
  Rg32i = 25,
  Rg16i = 26,
  Rg8i = 27,
  R16i = 28,
  R8i = 29,
  Rgba32ui = 30,
  Rgba16ui = 31,
  Rgba8ui = 32,
  R32ui = 33,
  Rgb10a2ui = 34,
  Rg32ui = 35,
  Rg16ui = 36,
  Rg8ui = 37,
  R16ui = 38,
  R8ui = 39,
  R64ui = 40,
  R64i = 41,
  Max = 0x7fffffff,
}

SpvOp :: enum u32 {
  Nop = 0,
  Undef = 1,
  SourceContinued = 2,
  Source = 3,
  SourceExtension = 4,
  Name = 5,
  MemberName = 6,
  String = 7,
  Line = 8,
  Extension = 10,
  ExtInstImport = 11,
  ExtInst = 12,
  MemoryModel = 14,
  EntryPoint = 15,
  ExecutionMode = 16,
  Capability = 17,
  TypeVoid = 19,
  TypeBool = 20,
  TypeInt = 21,
  TypeFloat = 22,
  TypeVector = 23,
  TypeMatrix = 24,
  TypeImage = 25,
  TypeSampler = 26,
  TypeSampledImage = 27,
  TypeArray = 28,
  TypeRuntimeArray = 29,
  TypeStruct = 30,
  TypeOpaque = 31,
  TypePointer = 32,
  TypeFunction = 33,
  TypeEvent = 34,
  TypeDeviceEvent = 35,
  TypeReserveId = 36,
  TypeQueue = 37,
  TypePipe = 38,
  TypeForwardPointer = 39,
  ConstantTrue = 41,
  ConstantFalse = 42,
  Constant = 43,
  ConstantComposite = 44,
  ConstantSampler = 45,
  ConstantNull = 46,
  SpecConstantTrue = 48,
  SpecConstantFalse = 49,
  SpecConstant = 50,
  SpecConstantComposite = 51,
  SpecConstantOp = 52,
  Function = 54,
  FunctionParameter = 55,
  FunctionEnd = 56,
  FunctionCall = 57,
  Variable = 59,
  ImageTexelPointer = 60,
  Load = 61,
  Store = 62,
  CopyMemory = 63,
  CopyMemorySized = 64,
  AccessChain = 65,
  InBoundsAccessChain = 66,
  PtrAccessChain = 67,
  ArrayLength = 68,
  GenericPtrMemSemantics = 69,
  InBoundsPtrAccessChain = 70,
  Decorate = 71,
  MemberDecorate = 72,
  DecorationGroup = 73,
  GroupDecorate = 74,
  GroupMemberDecorate = 75,
  VectorExtractDynamic = 77,
  VectorInsertDynamic = 78,
  VectorShuffle = 79,
  CompositeConstruct = 80,
  CompositeExtract = 81,
  CompositeInsert = 82,
  CopyObject = 83,
  Transpose = 84,
  SampledImage = 86,
  ImageSampleImplicitLod = 87,
  ImageSampleExplicitLod = 88,
  ImageSampleDrefImplicitLod = 89,
  ImageSampleDrefExplicitLod = 90,
  ImageSampleProjImplicitLod = 91,
  ImageSampleProjExplicitLod = 92,
  ImageSampleProjDrefImplicitLod = 93,
  ImageSampleProjDrefExplicitLod = 94,
  ImageFetch = 95,
  ImageGather = 96,
  ImageDrefGather = 97,
  ImageRead = 98,
  ImageWrite = 99,
  Image = 100,
  ImageQueryFormat = 101,
  ImageQueryOrder = 102,
  ImageQuerySizeLod = 103,
  ImageQuerySize = 104,
  ImageQueryLod = 105,
  ImageQueryLevels = 106,
  ImageQuerySamples = 107,
  ConvertFToU = 109,
  ConvertFToS = 110,
  ConvertSToF = 111,
  ConvertUToF = 112,
  UConvert = 113,
  SConvert = 114,
  FConvert = 115,
  QuantizeToF16 = 116,
  ConvertPtrToU = 117,
  SatConvertSToU = 118,
  SatConvertUToS = 119,
  ConvertUToPtr = 120,
  PtrCastToGeneric = 121,
  GenericCastToPtr = 122,
  GenericCastToPtrExplicit = 123,
  Bitcast = 124,
  SNegate = 126,
  FNegate = 127,
  IAdd = 128,
  FAdd = 129,
  ISub = 130,
  FSub = 131,
  IMul = 132,
  FMul = 133,
  UDiv = 134,
  SDiv = 135,
  FDiv = 136,
  UMod = 137,
  SRem = 138,
  SMod = 139,
  FRem = 140,
  FMod = 141,
  VectorTimesScalar = 142,
  MatrixTimesScalar = 143,
  VectorTimesMatrix = 144,
  MatrixTimesVector = 145,
  MatrixTimesMatrix = 146,
  OuterProduct = 147,
  Dot = 148,
  IAddCarry = 149,
  ISubBorrow = 150,
  UMulExtended = 151,
  SMulExtended = 152,
  Any = 154,
  All = 155,
  IsNan = 156,
  IsInf = 157,
  IsFinite = 158,
  IsNormal = 159,
  SignBitSet = 160,
  LessOrGreater = 161,
  Ordered = 162,
  Unordered = 163,
  LogicalEqual = 164,
  LogicalNotEqual = 165,
  LogicalOr = 166,
  LogicalAnd = 167,
  LogicalNot = 168,
  Select = 169,
  IEqual = 170,
  INotEqual = 171,
  UGreaterThan = 172,
  SGreaterThan = 173,
  UGreaterThanEqual = 174,
  SGreaterThanEqual = 175,
  ULessThan = 176,
  SLessThan = 177,
  ULessThanEqual = 178,
  SLessThanEqual = 179,
  FOrdEqual = 180,
  FUnordEqual = 181,
  FOrdNotEqual = 182,
  FUnordNotEqual = 183,
  FOrdLessThan = 184,
  FUnordLessThan = 185,
  FOrdGreaterThan = 186,
  FUnordGreaterThan = 187,
  FOrdLessThanEqual = 188,
  FUnordLessThanEqual = 189,
  FOrdGreaterThanEqual = 190,
  FUnordGreaterThanEqual = 191,
  ShiftRightLogical = 194,
  ShiftRightArithmetic = 195,
  ShiftLeftLogical = 196,
  BitwiseOr = 197,
  BitwiseXor = 198,
  BitwiseAnd = 199,
  Not = 200,
  BitFieldInsert = 201,
  BitFieldSExtract = 202,
  BitFieldUExtract = 203,
  BitReverse = 204,
  BitCount = 205,
  DPdx = 207,
  DPdy = 208,
  Fwidth = 209,
  DPdxFine = 210,
  DPdyFine = 211,
  FwidthFine = 212,
  DPdxCoarse = 213,
  DPdyCoarse = 214,
  FwidthCoarse = 215,
  EmitVertex = 218,
  EndPrimitive = 219,
  EmitStreamVertex = 220,
  EndStreamPrimitive = 221,
  ControlBarrier = 224,
  MemoryBarrier = 225,
  AtomicLoad = 227,
  AtomicStore = 228,
  AtomicExchange = 229,
  AtomicCompareExchange = 230,
  AtomicCompareExchangeWeak = 231,
  AtomicIIncrement = 232,
  AtomicIDecrement = 233,
  AtomicIAdd = 234,
  AtomicISub = 235,
  AtomicSMin = 236,
  AtomicUMin = 237,
  AtomicSMax = 238,
  AtomicUMax = 239,
  AtomicAnd = 240,
  AtomicOr = 241,
  AtomicXor = 242,
  Phi = 245,
  LoopMerge = 246,
  SelectionMerge = 247,
  Label = 248,
  Branch = 249,
  BranchConditional = 250,
  Switch = 251,
  Kill = 252,
  Return = 253,
  ReturnValue = 254,
  Unreachable = 255,
  LifetimeStart = 256,
  LifetimeStop = 257,
  GroupAsyncCopy = 259,
  GroupWaitEvents = 260,
  GroupAll = 261,
  GroupAny = 262,
  GroupBroadcast = 263,
  GroupIAdd = 264,
  GroupFAdd = 265,
  GroupFMin = 266,
  GroupUMin = 267,
  GroupSMin = 268,
  GroupFMax = 269,
  GroupUMax = 270,
  GroupSMax = 271,
  ReadPipe = 274,
  WritePipe = 275,
  ReservedReadPipe = 276,
  ReservedWritePipe = 277,
  ReserveReadPipePackets = 278,
  ReserveWritePipePackets = 279,
  CommitReadPipe = 280,
  CommitWritePipe = 281,
  IsValidReserveId = 282,
  GetNumPipePackets = 283,
  GetMaxPipePackets = 284,
  GroupReserveReadPipePackets = 285,
  GroupReserveWritePipePackets = 286,
  GroupCommitReadPipe = 287,
  GroupCommitWritePipe = 288,
  EnqueueMarker = 291,
  EnqueueKernel = 292,
  GetKernelNDrangeSubGroupCount = 293,
  GetKernelNDrangeMaxSubGroupSize = 294,
  GetKernelWorkGroupSize = 295,
  GetKernelPreferredWorkGroupSizeMultiple = 296,
  RetainEvent = 297,
  ReleaseEvent = 298,
  CreateUserEvent = 299,
  IsValidEvent = 300,
  SetUserEventStatus = 301,
  CaptureEventProfilingInfo = 302,
  GetDefaultQueue = 303,
  BuildNDRange = 304,
  ImageSparseSampleImplicitLod = 305,
  ImageSparseSampleExplicitLod = 306,
  ImageSparseSampleDrefImplicitLod = 307,
  ImageSparseSampleDrefExplicitLod = 308,
  ImageSparseSampleProjImplicitLod = 309,
  ImageSparseSampleProjExplicitLod = 310,
  ImageSparseSampleProjDrefImplicitLod = 311,
  ImageSparseSampleProjDrefExplicitLod = 312,
  ImageSparseFetch = 313,
  ImageSparseGather = 314,
  ImageSparseDrefGather = 315,
  ImageSparseTexelsResident = 316,
  NoLine = 317,
  AtomicFlagTestAndSet = 318,
  AtomicFlagClear = 319,
  ImageSparseRead = 320,
  SizeOf = 321,
  TypePipeStorage = 322,
  ConstantPipeStorage = 323,
  CreatePipeFromPipeStorage = 324,
  GetKernelLocalSizeForSubgroupCount = 325,
  GetKernelMaxNumSubgroups = 326,
  TypeNamedBarrier = 327,
  NamedBarrierInitialize = 328,
  MemoryNamedBarrier = 329,
  ModuleProcessed = 330,
  ExecutionModeId = 331,
  DecorateId = 332,
  GroupNonUniformElect = 333,
  GroupNonUniformAll = 334,
  GroupNonUniformAny = 335,
  GroupNonUniformAllEqual = 336,
  GroupNonUniformBroadcast = 337,
  GroupNonUniformBroadcastFirst = 338,
  GroupNonUniformBallot = 339,
  GroupNonUniformInverseBallot = 340,
  GroupNonUniformBallotBitExtract = 341,
  GroupNonUniformBallotBitCount = 342,
  GroupNonUniformBallotFindLSB = 343,
  GroupNonUniformBallotFindMSB = 344,
  GroupNonUniformShuffle = 345,
  GroupNonUniformShuffleXor = 346,
  GroupNonUniformShuffleUp = 347,
  GroupNonUniformShuffleDown = 348,
  GroupNonUniformIAdd = 349,
  GroupNonUniformFAdd = 350,
  GroupNonUniformIMul = 351,
  GroupNonUniformFMul = 352,
  GroupNonUniformSMin = 353,
  GroupNonUniformUMin = 354,
  GroupNonUniformFMin = 355,
  GroupNonUniformSMax = 356,
  GroupNonUniformUMax = 357,
  GroupNonUniformFMax = 358,
  GroupNonUniformBitwiseAnd = 359,
  GroupNonUniformBitwiseOr = 360,
  GroupNonUniformBitwiseXor = 361,
  GroupNonUniformLogicalAnd = 362,
  GroupNonUniformLogicalOr = 363,
  GroupNonUniformLogicalXor = 364,
  GroupNonUniformQuadBroadcast = 365,
  GroupNonUniformQuadSwap = 366,
  CopyLogical = 400,
  PtrEqual = 401,
  PtrNotEqual = 402,
  PtrDiff = 403,
  ColorAttachmentReadEXT = 4160,
  DepthAttachmentReadEXT = 4161,
  StencilAttachmentReadEXT = 4162,
  TypeTensorARM = 4163,
  TensorReadARM = 4164,
  TensorWriteARM = 4165,
  TensorQuerySizeARM = 4166,
  GraphConstantARM = 4181,
  GraphEntryPointARM = 4182,
  GraphARM = 4183,
  GraphInputARM = 4184,
  GraphSetOutputARM = 4185,
  GraphEndARM = 4186,
  TypeGraphARM = 4190,
  BitcastExtractEXT = 4195,
  TerminateInvocation = 4416,
  TypeUntypedPointerKHR = 4417,
  UntypedVariableKHR = 4418,
  UntypedAccessChainKHR = 4419,
  UntypedInBoundsAccessChainKHR = 4420,
  SubgroupBallotKHR = 4421,
  SubgroupFirstInvocationKHR = 4422,
  UntypedPtrAccessChainKHR = 4423,
  UntypedInBoundsPtrAccessChainKHR = 4424,
  UntypedArrayLengthKHR = 4425,
  UntypedPrefetchKHR = 4426,
  FmaKHR = 4427,
  SubgroupAllKHR = 4428,
  SubgroupAnyKHR = 4429,
  SubgroupAllEqualKHR = 4430,
  GroupNonUniformRotateKHR = 4431,
  SubgroupReadInvocationKHR = 4432,
  ExtInstWithForwardRefsKHR = 4433,
  UntypedGroupAsyncCopyKHR = 4434,
  TraceRayKHR = 4445,
  ExecuteCallableKHR = 4446,
  ConvertUToAccelerationStructureKHR = 4447,
  IgnoreIntersectionKHR = 4448,
  TerminateRayKHR = 4449,
  SDot = 4450,
  SDotKHR = 4450,
  UDot = 4451,
  UDotKHR = 4451,
  SUDot = 4452,
  SUDotKHR = 4452,
  SDotAccSat = 4453,
  SDotAccSatKHR = 4453,
  UDotAccSat = 4454,
  UDotAccSatKHR = 4454,
  SUDotAccSat = 4455,
  SUDotAccSatKHR = 4455,
  TypeCooperativeMatrixKHR = 4456,
  CooperativeMatrixLoadKHR = 4457,
  CooperativeMatrixStoreKHR = 4458,
  CooperativeMatrixMulAddKHR = 4459,
  CooperativeMatrixLengthKHR = 4460,
  ConstantCompositeReplicateEXT = 4461,
  SpecConstantCompositeReplicateEXT = 4462,
  CompositeConstructReplicateEXT = 4463,
  TypeRayQueryKHR = 4472,
  RayQueryInitializeKHR = 4473,
  RayQueryTerminateKHR = 4474,
  RayQueryGenerateIntersectionKHR = 4475,
  RayQueryConfirmIntersectionKHR = 4476,
  RayQueryProceedKHR = 4477,
  RayQueryGetIntersectionTypeKHR = 4479,
  ImageSampleWeightedQCOM = 4480,
  ImageBoxFilterQCOM = 4481,
  ImageBlockMatchSSDQCOM = 4482,
  ImageBlockMatchSADQCOM = 4483,
  BitCastArrayQCOM = 4497,
  ImageBlockMatchWindowSSDQCOM = 4500,
  ImageBlockMatchWindowSADQCOM = 4501,
  ImageBlockMatchGatherSSDQCOM = 4502,
  ImageBlockMatchGatherSADQCOM = 4503,
  CompositeConstructCoopMatQCOM = 4540,
  CompositeExtractCoopMatQCOM = 4541,
  ExtractSubArrayQCOM = 4542,
  ImageGatherQCOM = 4545,
  GroupIAddNonUniformAMD = 5000,
  GroupFAddNonUniformAMD = 5001,
  GroupFMinNonUniformAMD = 5002,
  GroupUMinNonUniformAMD = 5003,
  GroupSMinNonUniformAMD = 5004,
  GroupFMaxNonUniformAMD = 5005,
  GroupUMaxNonUniformAMD = 5006,
  GroupSMaxNonUniformAMD = 5007,
  FragmentMaskFetchAMD = 5011,
  FragmentFetchAMD = 5012,
  ReadClockKHR = 5056,
  AllocateNodePayloadsAMDX = 5074,
  EnqueueNodePayloadsAMDX = 5075,
  TypeNodePayloadArrayAMDX = 5076,
  FinishWritingNodePayloadAMDX = 5078,
  NodePayloadArrayLengthAMDX = 5090,
  IsNodePayloadValidAMDX = 5101,
  ConstantStringAMDX = 5103,
  SpecConstantStringAMDX = 5104,
  GroupNonUniformQuadAllKHR = 5110,
  GroupNonUniformQuadAnyKHR = 5111,
  TypeBufferEXT = 5115,
  BufferPointerEXT = 5119,
  AbortKHR = 5121,
  UntypedImageTexelPointerEXT = 5126,
  MemberDecorateIdEXT = 5127,
  ConstantSizeOfEXT = 5129,
  ConstantDataKHR = 5147,
  SpecConstantDataKHR = 5148,
  PoisonKHR = 5158,
  FreezeKHR = 5159,
  HitObjectRecordHitMotionNV = 5249,
  HitObjectRecordHitWithIndexMotionNV = 5250,
  HitObjectRecordMissMotionNV = 5251,
  HitObjectGetWorldToObjectNV = 5252,
  HitObjectGetObjectToWorldNV = 5253,
  HitObjectGetObjectRayDirectionNV = 5254,
  HitObjectGetObjectRayOriginNV = 5255,
  HitObjectTraceRayMotionNV = 5256,
  HitObjectGetShaderRecordBufferHandleNV = 5257,
  HitObjectGetShaderBindingTableRecordIndexNV = 5258,
  HitObjectRecordEmptyNV = 5259,
  HitObjectTraceRayNV = 5260,
  HitObjectRecordHitNV = 5261,
  HitObjectRecordHitWithIndexNV = 5262,
  HitObjectRecordMissNV = 5263,
  HitObjectExecuteShaderNV = 5264,
  HitObjectGetCurrentTimeNV = 5265,
  HitObjectGetAttributesNV = 5266,
  HitObjectGetHitKindNV = 5267,
  HitObjectGetPrimitiveIndexNV = 5268,
  HitObjectGetGeometryIndexNV = 5269,
  HitObjectGetInstanceIdNV = 5270,
  HitObjectGetInstanceCustomIndexNV = 5271,
  HitObjectGetWorldRayDirectionNV = 5272,
  HitObjectGetWorldRayOriginNV = 5273,
  HitObjectGetRayTMaxNV = 5274,
  HitObjectGetRayTMinNV = 5275,
  HitObjectIsEmptyNV = 5276,
  HitObjectIsHitNV = 5277,
  HitObjectIsMissNV = 5278,
  ReorderThreadWithHitObjectNV = 5279,
  ReorderThreadWithHintNV = 5280,
  TypeHitObjectNV = 5281,
  ImageSampleFootprintNV = 5283,
  TypeCooperativeVectorNV = 5288,
  TypeVectorIdEXT = 5288,
  CooperativeVectorMatrixMulNV = 5289,
  CooperativeVectorOuterProductAccumulateNV = 5290,
  CooperativeVectorReduceSumAccumulateNV = 5291,
  CooperativeVectorMatrixMulAddNV = 5292,
  CooperativeMatrixConvertNV = 5293,
  EmitMeshTasksEXT = 5294,
  SetMeshOutputsEXT = 5295,
  GroupNonUniformPartitionEXT = 5296,
  GroupNonUniformPartitionNV = 5296,
  WritePackedPrimitiveIndices4x8NV = 5299,
  FetchMicroTriangleVertexPositionNV = 5300,
  FetchMicroTriangleVertexBarycentricNV = 5301,
  CooperativeVectorLoadNV = 5302,
  CooperativeVectorStoreNV = 5303,
  HitObjectRecordFromQueryEXT = 5304,
  HitObjectRecordMissEXT = 5305,
  HitObjectRecordMissMotionEXT = 5306,
  HitObjectGetIntersectionTriangleVertexPositionsEXT = 5307,
  HitObjectGetRayFlagsEXT = 5308,
  HitObjectSetShaderBindingTableRecordIndexEXT = 5309,
  HitObjectReorderExecuteShaderEXT = 5310,
  HitObjectTraceReorderExecuteEXT = 5311,
  HitObjectTraceMotionReorderExecuteEXT = 5312,
  TypeHitObjectEXT = 5313,
  ReorderThreadWithHintEXT = 5314,
  ReorderThreadWithHitObjectEXT = 5315,
  HitObjectTraceRayEXT = 5316,
  HitObjectTraceRayMotionEXT = 5317,
  HitObjectRecordEmptyEXT = 5318,
  HitObjectExecuteShaderEXT = 5319,
  HitObjectGetCurrentTimeEXT = 5320,
  HitObjectGetAttributesEXT = 5321,
  HitObjectGetHitKindEXT = 5322,
  HitObjectGetPrimitiveIndexEXT = 5323,
  HitObjectGetGeometryIndexEXT = 5324,
  HitObjectGetInstanceIdEXT = 5325,
  HitObjectGetInstanceCustomIndexEXT = 5326,
  HitObjectGetObjectRayOriginEXT = 5327,
  HitObjectGetObjectRayDirectionEXT = 5328,
  HitObjectGetWorldRayDirectionEXT = 5329,
  HitObjectGetWorldRayOriginEXT = 5330,
  HitObjectGetObjectToWorldEXT = 5331,
  HitObjectGetWorldToObjectEXT = 5332,
  HitObjectGetRayTMaxEXT = 5333,
  ReportIntersectionKHR = 5334,
  ReportIntersectionNV = 5334,
  IgnoreIntersectionNV = 5335,
  TerminateRayNV = 5336,
  TraceNV = 5337,
  TraceMotionNV = 5338,
  TraceRayMotionNV = 5339,
  RayQueryGetIntersectionTriangleVertexPositionsKHR = 5340,
  TypeAccelerationStructureKHR = 5341,
  TypeAccelerationStructureNV = 5341,
  ExecuteCallableNV = 5344,
  RayQueryGetClusterIdNV = 5345,
  RayQueryGetIntersectionClusterIdNV = 5345,
  HitObjectGetClusterIdNV = 5346,
  HitObjectGetRayTMinEXT = 5347,
  HitObjectGetShaderBindingTableRecordIndexEXT = 5348,
  HitObjectGetShaderRecordBufferHandleEXT = 5349,
  HitObjectIsEmptyEXT = 5350,
  HitObjectIsHitEXT = 5351,
  HitObjectIsMissEXT = 5352,
  TypeCooperativeMatrixNV = 5358,
  CooperativeMatrixLoadNV = 5359,
  CooperativeMatrixStoreNV = 5360,
  CooperativeMatrixMulAddNV = 5361,
  CooperativeMatrixLengthNV = 5362,
  BeginInvocationInterlockEXT = 5364,
  EndInvocationInterlockEXT = 5365,
  CooperativeMatrixReduceNV = 5366,
  CooperativeMatrixLoadTensorNV = 5367,
  CooperativeMatrixStoreTensorNV = 5368,
  CooperativeMatrixPerElementOpNV = 5369,
  TypeTensorLayoutNV = 5370,
  TypeTensorViewNV = 5371,
  CreateTensorLayoutNV = 5372,
  TensorLayoutSetDimensionNV = 5373,
  TensorLayoutSetStrideNV = 5374,
  TensorLayoutSliceNV = 5375,
  TensorLayoutSetClampValueNV = 5376,
  CreateTensorViewNV = 5377,
  TensorViewSetDimensionNV = 5378,
  TensorViewSetStrideNV = 5379,
  DemoteToHelperInvocation = 5380,
  DemoteToHelperInvocationEXT = 5380,
  IsHelperInvocationEXT = 5381,
  TensorViewSetClipNV = 5382,
  TensorLayoutSetBlockSizeNV = 5384,
  CooperativeMatrixTransposeNV = 5390,
  ConvertUToImageNV = 5391,
  ConvertUToSamplerNV = 5392,
  ConvertImageToUNV = 5393,
  ConvertSamplerToUNV = 5394,
  ConvertUToSampledImageNV = 5395,
  ConvertSampledImageToUNV = 5396,
  SamplerImageAddressingModeNV = 5397,
  RawAccessChainNV = 5398,
  RayQueryGetIntersectionSpherePositionNV = 5427,
  RayQueryGetIntersectionSphereRadiusNV = 5428,
  RayQueryGetIntersectionLSSPositionsNV = 5429,
  RayQueryGetIntersectionLSSRadiiNV = 5430,
  RayQueryGetIntersectionLSSHitValueNV = 5431,
  HitObjectGetSpherePositionNV = 5432,
  HitObjectGetSphereRadiusNV = 5433,
  HitObjectGetLSSPositionsNV = 5434,
  HitObjectGetLSSRadiiNV = 5435,
  HitObjectIsSphereHitNV = 5436,
  HitObjectIsLSSHitNV = 5437,
  RayQueryIsSphereHitNV = 5438,
  RayQueryIsLSSHitNV = 5439,
  SubgroupShuffleINTEL = 5571,
  SubgroupShuffleDownINTEL = 5572,
  SubgroupShuffleUpINTEL = 5573,
  SubgroupShuffleXorINTEL = 5574,
  SubgroupBlockReadINTEL = 5575,
  SubgroupBlockWriteINTEL = 5576,
  SubgroupImageBlockReadINTEL = 5577,
  SubgroupImageBlockWriteINTEL = 5578,
  SubgroupImageMediaBlockReadINTEL = 5580,
  SubgroupImageMediaBlockWriteINTEL = 5581,
  UCountLeadingZerosINTEL = 5585,
  UCountTrailingZerosINTEL = 5586,
  AbsISubINTEL = 5587,
  AbsUSubINTEL = 5588,
  IAddSatINTEL = 5589,
  UAddSatINTEL = 5590,
  IAverageINTEL = 5591,
  UAverageINTEL = 5592,
  IAverageRoundedINTEL = 5593,
  UAverageRoundedINTEL = 5594,
  ISubSatINTEL = 5595,
  USubSatINTEL = 5596,
  IMul32x16INTEL = 5597,
  UMul32x16INTEL = 5598,
  ConstantFunctionPointerINTEL = 5600,
  FunctionPointerCallINTEL = 5601,
  AsmTargetINTEL = 5609,
  AsmINTEL = 5610,
  AsmCallINTEL = 5611,
  AtomicFMinEXT = 5614,
  AtomicFMaxEXT = 5615,
  AssumeTrueKHR = 5630,
  ExpectKHR = 5631,
  DecorateString = 5632,
  DecorateStringGOOGLE = 5632,
  MemberDecorateString = 5633,
  MemberDecorateStringGOOGLE = 5633,
  VmeImageINTEL = 5699,
  TypeVmeImageINTEL = 5700,
  TypeAvcImePayloadINTEL = 5701,
  TypeAvcRefPayloadINTEL = 5702,
  TypeAvcSicPayloadINTEL = 5703,
  TypeAvcMcePayloadINTEL = 5704,
  TypeAvcMceResultINTEL = 5705,
  TypeAvcImeResultINTEL = 5706,
  TypeAvcImeResultSingleReferenceStreamoutINTEL = 5707,
  TypeAvcImeResultDualReferenceStreamoutINTEL = 5708,
  TypeAvcImeSingleReferenceStreaminINTEL = 5709,
  TypeAvcImeDualReferenceStreaminINTEL = 5710,
  TypeAvcRefResultINTEL = 5711,
  TypeAvcSicResultINTEL = 5712,
  SubgroupAvcMceGetDefaultInterBaseMultiReferencePenaltyINTEL = 5713,
  SubgroupAvcMceSetInterBaseMultiReferencePenaltyINTEL = 5714,
  SubgroupAvcMceGetDefaultInterShapePenaltyINTEL = 5715,
  SubgroupAvcMceSetInterShapePenaltyINTEL = 5716,
  SubgroupAvcMceGetDefaultInterDirectionPenaltyINTEL = 5717,
  SubgroupAvcMceSetInterDirectionPenaltyINTEL = 5718,
  SubgroupAvcMceGetDefaultIntraLumaShapePenaltyINTEL = 5719,
  SubgroupAvcMceGetDefaultInterMotionVectorCostTableINTEL = 5720,
  SubgroupAvcMceGetDefaultHighPenaltyCostTableINTEL = 5721,
  SubgroupAvcMceGetDefaultMediumPenaltyCostTableINTEL = 5722,
  SubgroupAvcMceGetDefaultLowPenaltyCostTableINTEL = 5723,
  SubgroupAvcMceSetMotionVectorCostFunctionINTEL = 5724,
  SubgroupAvcMceGetDefaultIntraLumaModePenaltyINTEL = 5725,
  SubgroupAvcMceGetDefaultNonDcLumaIntraPenaltyINTEL = 5726,
  SubgroupAvcMceGetDefaultIntraChromaModeBasePenaltyINTEL = 5727,
  SubgroupAvcMceSetAcOnlyHaarINTEL = 5728,
  SubgroupAvcMceSetSourceInterlacedFieldPolarityINTEL = 5729,
  SubgroupAvcMceSetSingleReferenceInterlacedFieldPolarityINTEL = 5730,
  SubgroupAvcMceSetDualReferenceInterlacedFieldPolaritiesINTEL = 5731,
  SubgroupAvcMceConvertToImePayloadINTEL = 5732,
  SubgroupAvcMceConvertToImeResultINTEL = 5733,
  SubgroupAvcMceConvertToRefPayloadINTEL = 5734,
  SubgroupAvcMceConvertToRefResultINTEL = 5735,
  SubgroupAvcMceConvertToSicPayloadINTEL = 5736,
  SubgroupAvcMceConvertToSicResultINTEL = 5737,
  SubgroupAvcMceGetMotionVectorsINTEL = 5738,
  SubgroupAvcMceGetInterDistortionsINTEL = 5739,
  SubgroupAvcMceGetBestInterDistortionsINTEL = 5740,
  SubgroupAvcMceGetInterMajorShapeINTEL = 5741,
  SubgroupAvcMceGetInterMinorShapeINTEL = 5742,
  SubgroupAvcMceGetInterDirectionsINTEL = 5743,
  SubgroupAvcMceGetInterMotionVectorCountINTEL = 5744,
  SubgroupAvcMceGetInterReferenceIdsINTEL = 5745,
  SubgroupAvcMceGetInterReferenceInterlacedFieldPolaritiesINTEL = 5746,
  SubgroupAvcImeInitializeINTEL = 5747,
  SubgroupAvcImeSetSingleReferenceINTEL = 5748,
  SubgroupAvcImeSetDualReferenceINTEL = 5749,
  SubgroupAvcImeRefWindowSizeINTEL = 5750,
  SubgroupAvcImeAdjustRefOffsetINTEL = 5751,
  SubgroupAvcImeConvertToMcePayloadINTEL = 5752,
  SubgroupAvcImeSetMaxMotionVectorCountINTEL = 5753,
  SubgroupAvcImeSetUnidirectionalMixDisableINTEL = 5754,
  SubgroupAvcImeSetEarlySearchTerminationThresholdINTEL = 5755,
  SubgroupAvcImeSetWeightedSadINTEL = 5756,
  SubgroupAvcImeEvaluateWithSingleReferenceINTEL = 5757,
  SubgroupAvcImeEvaluateWithDualReferenceINTEL = 5758,
  SubgroupAvcImeEvaluateWithSingleReferenceStreaminINTEL = 5759,
  SubgroupAvcImeEvaluateWithDualReferenceStreaminINTEL = 5760,
  SubgroupAvcImeEvaluateWithSingleReferenceStreamoutINTEL = 5761,
  SubgroupAvcImeEvaluateWithDualReferenceStreamoutINTEL = 5762,
  SubgroupAvcImeEvaluateWithSingleReferenceStreaminoutINTEL = 5763,
  SubgroupAvcImeEvaluateWithDualReferenceStreaminoutINTEL = 5764,
  SubgroupAvcImeConvertToMceResultINTEL = 5765,
  SubgroupAvcImeGetSingleReferenceStreaminINTEL = 5766,
  SubgroupAvcImeGetDualReferenceStreaminINTEL = 5767,
  SubgroupAvcImeStripSingleReferenceStreamoutINTEL = 5768,
  SubgroupAvcImeStripDualReferenceStreamoutINTEL = 5769,
  SubgroupAvcImeGetStreamoutSingleReferenceMajorShapeMotionVectorsINTEL = 5770,
  SubgroupAvcImeGetStreamoutSingleReferenceMajorShapeDistortionsINTEL = 5771,
  SubgroupAvcImeGetStreamoutSingleReferenceMajorShapeReferenceIdsINTEL = 5772,
  SubgroupAvcImeGetStreamoutDualReferenceMajorShapeMotionVectorsINTEL = 5773,
  SubgroupAvcImeGetStreamoutDualReferenceMajorShapeDistortionsINTEL = 5774,
  SubgroupAvcImeGetStreamoutDualReferenceMajorShapeReferenceIdsINTEL = 5775,
  SubgroupAvcImeGetBorderReachedINTEL = 5776,
  SubgroupAvcImeGetTruncatedSearchIndicationINTEL = 5777,
  SubgroupAvcImeGetUnidirectionalEarlySearchTerminationINTEL = 5778,
  SubgroupAvcImeGetWeightingPatternMinimumMotionVectorINTEL = 5779,
  SubgroupAvcImeGetWeightingPatternMinimumDistortionINTEL = 5780,
  SubgroupAvcFmeInitializeINTEL = 5781,
  SubgroupAvcBmeInitializeINTEL = 5782,
  SubgroupAvcRefConvertToMcePayloadINTEL = 5783,
  SubgroupAvcRefSetBidirectionalMixDisableINTEL = 5784,
  SubgroupAvcRefSetBilinearFilterEnableINTEL = 5785,
  SubgroupAvcRefEvaluateWithSingleReferenceINTEL = 5786,
  SubgroupAvcRefEvaluateWithDualReferenceINTEL = 5787,
  SubgroupAvcRefEvaluateWithMultiReferenceINTEL = 5788,
  SubgroupAvcRefEvaluateWithMultiReferenceInterlacedINTEL = 5789,
  SubgroupAvcRefConvertToMceResultINTEL = 5790,
  SubgroupAvcSicInitializeINTEL = 5791,
  SubgroupAvcSicConfigureSkcINTEL = 5792,
  SubgroupAvcSicConfigureIpeLumaINTEL = 5793,
  SubgroupAvcSicConfigureIpeLumaChromaINTEL = 5794,
  SubgroupAvcSicGetMotionVectorMaskINTEL = 5795,
  SubgroupAvcSicConvertToMcePayloadINTEL = 5796,
  SubgroupAvcSicSetIntraLumaShapePenaltyINTEL = 5797,
  SubgroupAvcSicSetIntraLumaModeCostFunctionINTEL = 5798,
  SubgroupAvcSicSetIntraChromaModeCostFunctionINTEL = 5799,
  SubgroupAvcSicSetBilinearFilterEnableINTEL = 5800,
  SubgroupAvcSicSetSkcForwardTransformEnableINTEL = 5801,
  SubgroupAvcSicSetBlockBasedRawSkipSadINTEL = 5802,
  SubgroupAvcSicEvaluateIpeINTEL = 5803,
  SubgroupAvcSicEvaluateWithSingleReferenceINTEL = 5804,
  SubgroupAvcSicEvaluateWithDualReferenceINTEL = 5805,
  SubgroupAvcSicEvaluateWithMultiReferenceINTEL = 5806,
  SubgroupAvcSicEvaluateWithMultiReferenceInterlacedINTEL = 5807,
  SubgroupAvcSicConvertToMceResultINTEL = 5808,
  SubgroupAvcSicGetIpeLumaShapeINTEL = 5809,
  SubgroupAvcSicGetBestIpeLumaDistortionINTEL = 5810,
  SubgroupAvcSicGetBestIpeChromaDistortionINTEL = 5811,
  SubgroupAvcSicGetPackedIpeLumaModesINTEL = 5812,
  SubgroupAvcSicGetIpeChromaModeINTEL = 5813,
  SubgroupAvcSicGetPackedSkcLumaCountThresholdINTEL = 5814,
  SubgroupAvcSicGetPackedSkcLumaSumThresholdINTEL = 5815,
  SubgroupAvcSicGetInterRawSadsINTEL = 5816,
  VariableLengthArrayINTEL = 5818,
  SaveMemoryINTEL = 5819,
  RestoreMemoryINTEL = 5820,
  ArbitraryFloatSinCosPiALTERA = 5840,
  ArbitraryFloatSinCosPiINTEL = 5840,
  ArbitraryFloatCastALTERA = 5841,
  ArbitraryFloatCastINTEL = 5841,
  ArbitraryFloatCastFromIntALTERA = 5842,
  ArbitraryFloatCastFromIntINTEL = 5842,
  ArbitraryFloatCastToIntALTERA = 5843,
  ArbitraryFloatCastToIntINTEL = 5843,
  ArbitraryFloatAddALTERA = 5846,
  ArbitraryFloatAddINTEL = 5846,
  ArbitraryFloatSubALTERA = 5847,
  ArbitraryFloatSubINTEL = 5847,
  ArbitraryFloatMulALTERA = 5848,
  ArbitraryFloatMulINTEL = 5848,
  ArbitraryFloatDivALTERA = 5849,
  ArbitraryFloatDivINTEL = 5849,
  ArbitraryFloatGTALTERA = 5850,
  ArbitraryFloatGTINTEL = 5850,
  ArbitraryFloatGEALTERA = 5851,
  ArbitraryFloatGEINTEL = 5851,
  ArbitraryFloatLTALTERA = 5852,
  ArbitraryFloatLTINTEL = 5852,
  ArbitraryFloatLEALTERA = 5853,
  ArbitraryFloatLEINTEL = 5853,
  ArbitraryFloatEQALTERA = 5854,
  ArbitraryFloatEQINTEL = 5854,
  ArbitraryFloatRecipALTERA = 5855,
  ArbitraryFloatRecipINTEL = 5855,
  ArbitraryFloatRSqrtALTERA = 5856,
  ArbitraryFloatRSqrtINTEL = 5856,
  ArbitraryFloatCbrtALTERA = 5857,
  ArbitraryFloatCbrtINTEL = 5857,
  ArbitraryFloatHypotALTERA = 5858,
  ArbitraryFloatHypotINTEL = 5858,
  ArbitraryFloatSqrtALTERA = 5859,
  ArbitraryFloatSqrtINTEL = 5859,
  ArbitraryFloatLogINTEL = 5860,
  ArbitraryFloatLog2INTEL = 5861,
  ArbitraryFloatLog10INTEL = 5862,
  ArbitraryFloatLog1pINTEL = 5863,
  ArbitraryFloatExpINTEL = 5864,
  ArbitraryFloatExp2INTEL = 5865,
  ArbitraryFloatExp10INTEL = 5866,
  ArbitraryFloatExpm1INTEL = 5867,
  ArbitraryFloatSinINTEL = 5868,
  ArbitraryFloatCosINTEL = 5869,
  ArbitraryFloatSinCosINTEL = 5870,
  ArbitraryFloatSinPiINTEL = 5871,
  ArbitraryFloatCosPiINTEL = 5872,
  ArbitraryFloatASinINTEL = 5873,
  ArbitraryFloatASinPiINTEL = 5874,
  ArbitraryFloatACosINTEL = 5875,
  ArbitraryFloatACosPiINTEL = 5876,
  ArbitraryFloatATanINTEL = 5877,
  ArbitraryFloatATanPiINTEL = 5878,
  ArbitraryFloatATan2INTEL = 5879,
  ArbitraryFloatPowINTEL = 5880,
  ArbitraryFloatPowRINTEL = 5881,
  ArbitraryFloatPowNINTEL = 5882,
  LoopControlINTEL = 5887,
  AliasDomainDeclINTEL = 5911,
  AliasScopeDeclINTEL = 5912,
  AliasScopeListDeclINTEL = 5913,
  FixedSqrtALTERA = 5923,
  FixedSqrtINTEL = 5923,
  FixedRecipALTERA = 5924,
  FixedRecipINTEL = 5924,
  FixedRsqrtALTERA = 5925,
  FixedRsqrtINTEL = 5925,
  FixedSinALTERA = 5926,
  FixedSinINTEL = 5926,
  FixedCosALTERA = 5927,
  FixedCosINTEL = 5927,
  FixedSinCosALTERA = 5928,
  FixedSinCosINTEL = 5928,
  FixedSinPiALTERA = 5929,
  FixedSinPiINTEL = 5929,
  FixedCosPiALTERA = 5930,
  FixedCosPiINTEL = 5930,
  FixedSinCosPiALTERA = 5931,
  FixedSinCosPiINTEL = 5931,
  FixedLogALTERA = 5932,
  FixedLogINTEL = 5932,
  FixedExpALTERA = 5933,
  FixedExpINTEL = 5933,
  PtrCastToCrossWorkgroupALTERA = 5934,
  PtrCastToCrossWorkgroupINTEL = 5934,
  CrossWorkgroupCastToPtrALTERA = 5938,
  CrossWorkgroupCastToPtrINTEL = 5938,
  ReadPipeBlockingALTERA = 5946,
  ReadPipeBlockingINTEL = 5946,
  WritePipeBlockingALTERA = 5947,
  WritePipeBlockingINTEL = 5947,
  FPGARegALTERA = 5949,
  FPGARegINTEL = 5949,
  RayQueryGetRayTMinKHR = 6016,
  RayQueryGetRayFlagsKHR = 6017,
  RayQueryGetIntersectionTKHR = 6018,
  RayQueryGetIntersectionInstanceCustomIndexKHR = 6019,
  RayQueryGetIntersectionInstanceIdKHR = 6020,
  RayQueryGetIntersectionInstanceShaderBindingTableRecordOffsetKHR = 6021,
  RayQueryGetIntersectionGeometryIndexKHR = 6022,
  RayQueryGetIntersectionPrimitiveIndexKHR = 6023,
  RayQueryGetIntersectionBarycentricsKHR = 6024,
  RayQueryGetIntersectionFrontFaceKHR = 6025,
  RayQueryGetIntersectionCandidateAABBOpaqueKHR = 6026,
  RayQueryGetIntersectionObjectRayDirectionKHR = 6027,
  RayQueryGetIntersectionObjectRayOriginKHR = 6028,
  RayQueryGetWorldRayDirectionKHR = 6029,
  RayQueryGetWorldRayOriginKHR = 6030,
  RayQueryGetIntersectionObjectToWorldKHR = 6031,
  RayQueryGetIntersectionWorldToObjectKHR = 6032,
  AtomicFAddEXT = 6035,
  TypeBufferSurfaceINTEL = 6086,
  TypeStructContinuedINTEL = 6090,
  ConstantCompositeContinuedINTEL = 6091,
  SpecConstantCompositeContinuedINTEL = 6092,
  CompositeConstructContinuedINTEL = 6096,
  ConvertFToBF16INTEL = 6116,
  ConvertBF16ToFINTEL = 6117,
  ControlBarrierArriveEXT = 6142,
  ControlBarrierArriveINTEL = 6142,
  ControlBarrierWaitEXT = 6143,
  ControlBarrierWaitINTEL = 6143,
  ArithmeticFenceEXT = 6145,
  TaskSequenceCreateALTERA = 6163,
  TaskSequenceCreateINTEL = 6163,
  TaskSequenceAsyncALTERA = 6164,
  TaskSequenceAsyncINTEL = 6164,
  TaskSequenceGetALTERA = 6165,
  TaskSequenceGetINTEL = 6165,
  TaskSequenceReleaseALTERA = 6166,
  TaskSequenceReleaseINTEL = 6166,
  TypeTaskSequenceALTERA = 6199,
  TypeTaskSequenceINTEL = 6199,
  SubgroupBlockPrefetchINTEL = 6221,
  Subgroup2DBlockLoadINTEL = 6231,
  Subgroup2DBlockLoadTransformINTEL = 6232,
  Subgroup2DBlockLoadTransposeINTEL = 6233,
  Subgroup2DBlockPrefetchINTEL = 6234,
  Subgroup2DBlockStoreINTEL = 6235,
  SubgroupMatrixMultiplyAccumulateINTEL = 6237,
  BitwiseFunctionINTEL = 6242,
  UntypedVariableLengthArrayINTEL = 6244,
  ConditionalExtensionINTEL = 6248,
  ConditionalEntryPointINTEL = 6249,
  ConditionalCapabilityINTEL = 6250,
  SpecConstantTargetINTEL = 6251,
  SpecConstantArchitectureINTEL = 6252,
  SpecConstantCapabilitiesINTEL = 6253,
  ConditionalCopyObjectINTEL = 6254,
  PredicatedLoadINTEL = 6258,
  PredicatedStoreINTEL = 6259,
  GroupIMulKHR = 6401,
  GroupFMulKHR = 6402,
  GroupBitwiseAndKHR = 6403,
  GroupBitwiseOrKHR = 6404,
  GroupBitwiseXorKHR = 6405,
  GroupLogicalAndKHR = 6406,
  GroupLogicalOrKHR = 6407,
  GroupLogicalXorKHR = 6408,
  RoundFToTF32INTEL = 6426,
  MaskedGatherINTEL = 6428,
  MaskedScatterINTEL = 6429,
  ConvertHandleToImageINTEL = 6529,
  ConvertHandleToSamplerINTEL = 6530,
  ConvertHandleToSampledImageINTEL = 6531,
  FDot2MixAcc32VALVE = 6916,
  FDot2MixAcc16VALVE = 6917,
  FDot4MixAcc32VALVE = 6918,
  Max = 0x7fffffff,
}


SpvStorageClass :: enum u32 {
  UniformConstant = 0,
  Input = 1,
  Uniform = 2,
  Output = 3,
  Workgroup = 4,
  CrossWorkgroup = 5,
  Private = 6,
  Function = 7,
  Generic = 8,
  PushConstant = 9,
  AtomicCounter = 10,
  Image = 11,
  StorageBuffer = 12,
  TileImageEXT = 4172,
  TileAttachmentQCOM = 4491,
  NodePayloadAMDX = 5068,
  CallableDataKHR = 5328,
  CallableDataNV = 5328,
  IncomingCallableDataKHR = 5329,
  IncomingCallableDataNV = 5329,
  RayPayloadKHR = 5338,
  RayPayloadNV = 5338,
  HitAttributeKHR = 5339,
  HitAttributeNV = 5339,
  IncomingRayPayloadKHR = 5342,
  IncomingRayPayloadNV = 5342,
  ShaderRecordBufferKHR = 5343,
  ShaderRecordBufferNV = 5343,
  PhysicalStorageBuffer = 5349,
  PhysicalStorageBufferEXT = 5349,
  HitObjectAttributeNV = 5385,
  TaskPayloadWorkgroupEXT = 5402,
  HitObjectAttributeEXT = 5411,
  CodeSectionINTEL = 5605,
  DeviceOnlyALTERA = 5936,
  DeviceOnlyINTEL = 5936,
  HostOnlyALTERA = 5937,
  HostOnlyINTEL = 5937,
  Max = 0x7fffffff,
}


SpvExecutionModel :: enum u32 {
  Vertex = 0,
  TessellationControl = 1,
  TessellationEvaluation = 2,
  Geometry = 3,
  Fragment = 4,
  GLCompute = 5,
  Kernel = 6,
  TaskNV = 5267,
  MeshNV = 5268,
  RayGenerationKHR = 5313,
  RayGenerationNV = 5313,
  IntersectionKHR = 5314,
  IntersectionNV = 5314,
  AnyHitKHR = 5315,
  AnyHitNV = 5315,
  ClosestHitKHR = 5316,
  ClosestHitNV = 5316,
  MissKHR = 5317,
  MissNV = 5317,
  CallableKHR = 5318,
  CallableNV = 5318,
  TaskEXT = 5364,
  MeshEXT = 5365,
  Max = 0x7fffffff,
}

SpvExecutionMode :: enum u32 {
  Invocations = 0,
  SpacingEqual = 1,
  SpacingFractionalEven = 2,
  SpacingFractionalOdd = 3,
  VertexOrderCw = 4,
  VertexOrderCcw = 5,
  PixelCenterInteger = 6,
  OriginUpperLeft = 7,
  OriginLowerLeft = 8,
  EarlyFragmentTests = 9,
  PointMode = 10,
  Xfb = 11,
  DepthReplacing = 12,
  DepthGreater = 14,
  DepthLess = 15,
  DepthUnchanged = 16,
  LocalSize = 17,
  LocalSizeHint = 18,
  InputPoints = 19,
  InputLines = 20,
  InputLinesAdjacency = 21,
  Triangles = 22,
  InputTrianglesAdjacency = 23,
  Quads = 24,
  Isolines = 25,
  OutputVertices = 26,
  OutputPoints = 27,
  OutputLineStrip = 28,
  OutputTriangleStrip = 29,
  VecTypeHint = 30,
  ContractionOff = 31,
  Initializer = 33,
  Finalizer = 34,
  SubgroupSize = 35,
  SubgroupsPerWorkgroup = 36,
  SubgroupsPerWorkgroupId = 37,
  LocalSizeId = 38,
  LocalSizeHintId = 39,
  NonCoherentColorAttachmentReadEXT = 4169,
  NonCoherentDepthAttachmentReadEXT = 4170,
  NonCoherentStencilAttachmentReadEXT = 4171,
  SubgroupUniformControlFlowKHR = 4421,
  PostDepthCoverage = 4446,
  DenormPreserve = 4459,
  DenormFlushToZero = 4460,
  SignedZeroInfNanPreserve = 4461,
  RoundingModeRTE = 4462,
  RoundingModeRTZ = 4463,
  NonCoherentTileAttachmentReadQCOM = 4489,
  TileShadingRateQCOM = 4490,
  EarlyAndLateFragmentTestsAMD = 5017,
  StencilRefReplacingEXT = 5027,
  CoalescingAMDX = 5069,
  IsApiEntryAMDX = 5070,
  MaxNodeRecursionAMDX = 5071,
  StaticNumWorkgroupsAMDX = 5072,
  ShaderIndexAMDX = 5073,
  MaxNumWorkgroupsAMDX = 5077,
  StencilRefUnchangedFrontAMD = 5079,
  StencilRefGreaterFrontAMD = 5080,
  StencilRefLessFrontAMD = 5081,
  StencilRefUnchangedBackAMD = 5082,
  StencilRefGreaterBackAMD = 5083,
  StencilRefLessBackAMD = 5084,
  QuadDerivativesKHR = 5088,
  RequireFullQuadsKHR = 5089,
  SharesInputWithAMDX = 5102,
  ArithmeticPoisonKHR = 5157,
  OutputLinesEXT = 5269,
  OutputLinesNV = 5269,
  OutputPrimitivesEXT = 5270,
  OutputPrimitivesNV = 5270,
  DerivativeGroupQuadsKHR = 5289,
  DerivativeGroupQuadsNV = 5289,
  DerivativeGroupLinearKHR = 5290,
  DerivativeGroupLinearNV = 5290,
  OutputTrianglesEXT = 5298,
  OutputTrianglesNV = 5298,
  PixelInterlockOrderedEXT = 5366,
  PixelInterlockUnorderedEXT = 5367,
  SampleInterlockOrderedEXT = 5368,
  SampleInterlockUnorderedEXT = 5369,
  ShadingRateInterlockOrderedEXT = 5370,
  ShadingRateInterlockUnorderedEXT = 5371,
  Shader64BitIndexingEXT = 5427,
  SharedLocalMemorySizeINTEL = 5618,
  RoundingModeRTPINTEL = 5620,
  RoundingModeRTNINTEL = 5621,
  FloatingPointModeALTINTEL = 5622,
  FloatingPointModeIEEEINTEL = 5623,
  MaxWorkgroupSizeINTEL = 5893,
  MaxWorkDimINTEL = 5894,
  NoGlobalOffsetINTEL = 5895,
  NumSIMDWorkitemsINTEL = 5896,
  SchedulerTargetFmaxMhzINTEL = 5903,
  MaximallyReconvergesKHR = 6023,
  FPFastMathDefault = 6028,
  OpacityMicromapIdKHR = 6031,
  StreamingInterfaceINTEL = 6154,
  RegisterMapInterfaceINTEL = 6160,
  NamedBarrierCountINTEL = 6417,
  MaximumRegistersINTEL = 6461,
  MaximumRegistersIdINTEL = 6462,
  NamedMaximumRegistersINTEL = 6463,
  Max = 0x7fffffff,
}


SpvCapability :: enum u32 {
  Matrix = 0,
  Shader = 1,
  Geometry = 2,
  Tessellation = 3,
  Addresses = 4,
  Linkage = 5,
  Kernel = 6,
  Vector16 = 7,
  Float16Buffer = 8,
  Float16 = 9,
  Float64 = 10,
  Int64 = 11,
  Int64Atomics = 12,
  ImageBasic = 13,
  ImageReadWrite = 14,
  ImageMipmap = 15,
  Pipes = 17,
  Groups = 18,
  DeviceEnqueue = 19,
  LiteralSampler = 20,
  AtomicStorage = 21,
  Int16 = 22,
  TessellationPointSize = 23,
  GeometryPointSize = 24,
  ImageGatherExtended = 25,
  StorageImageMultisample = 27,
  UniformBufferArrayDynamicIndexing = 28,
  SampledImageArrayDynamicIndexing = 29,
  StorageBufferArrayDynamicIndexing = 30,
  StorageImageArrayDynamicIndexing = 31,
  ClipDistance = 32,
  CullDistance = 33,
  ImageCubeArray = 34,
  SampleRateShading = 35,
  ImageRect = 36,
  SampledRect = 37,
  GenericPointer = 38,
  Int8 = 39,
  InputAttachment = 40,
  SparseResidency = 41,
  MinLod = 42,
  Sampled1D = 43,
  Image1D = 44,
  SampledCubeArray = 45,
  SampledBuffer = 46,
  ImageBuffer = 47,
  ImageMSArray = 48,
  StorageImageExtendedFormats = 49,
  ImageQuery = 50,
  DerivativeControl = 51,
  InterpolationFunction = 52,
  TransformFeedback = 53,
  GeometryStreams = 54,
  StorageImageReadWithoutFormat = 55,
  StorageImageWriteWithoutFormat = 56,
  MultiViewport = 57,
  SubgroupDispatch = 58,
  NamedBarrier = 59,
  PipeStorage = 60,
  GroupNonUniform = 61,
  GroupNonUniformVote = 62,
  GroupNonUniformArithmetic = 63,
  GroupNonUniformBallot = 64,
  GroupNonUniformShuffle = 65,
  GroupNonUniformShuffleRelative = 66,
  GroupNonUniformClustered = 67,
  GroupNonUniformQuad = 68,
  ShaderLayer = 69,
  ShaderViewportIndex = 70,
  UniformDecoration = 71,
  CoreBuiltinsARM = 4165,
  TileImageColorReadAccessEXT = 4166,
  TileImageDepthReadAccessEXT = 4167,
  TileImageStencilReadAccessEXT = 4168,
  TensorsARM = 4174,
  StorageTensorArrayDynamicIndexingARM = 4175,
  StorageTensorArrayNonUniformIndexingARM = 4176,
  GraphARM = 4191,
  CooperativeMatrixLayoutsARM = 4201,
  Float8EXT = 4212,
  Float8CooperativeMatrixEXT = 4213,
  Float6EXT = 4228,
  Float4EXT = 4229,
  Float8UnsignedE8M0EXT = 4230,
  MXInt8EXT = 4231,
  BitcastExtractEXT = 4232,
  FragmentShadingRateKHR = 4422,
  SubgroupBallotKHR = 4423,
  DrawParameters = 4427,
  WorkgroupMemoryExplicitLayoutKHR = 4428,
  WorkgroupMemoryExplicitLayout8BitAccessKHR = 4429,
  WorkgroupMemoryExplicitLayout16BitAccessKHR = 4430,
  SubgroupVoteKHR = 4431,
  StorageBuffer16BitAccess = 4433,
  StorageUniformBufferBlock16 = 4433,
  StorageUniform16 = 4434,
  UniformAndStorageBuffer16BitAccess = 4434,
  StoragePushConstant16 = 4435,
  StorageInputOutput16 = 4436,
  DeviceGroup = 4437,
  MultiView = 4439,
  VariablePointersStorageBuffer = 4441,
  VariablePointers = 4442,
  AtomicStorageOps = 4445,
  SampleMaskPostDepthCoverage = 4447,
  StorageBuffer8BitAccess = 4448,
  UniformAndStorageBuffer8BitAccess = 4449,
  StoragePushConstant8 = 4450,
  DenormPreserve = 4464,
  DenormFlushToZero = 4465,
  SignedZeroInfNanPreserve = 4466,
  RoundingModeRTE = 4467,
  RoundingModeRTZ = 4468,
  RayQueryProvisionalKHR = 4471,
  RayQueryKHR = 4472,
  UntypedPointersKHR = 4473,
  RayTraversalPrimitiveCullingKHR = 4478,
  RayTracingKHR = 4479,
  TextureSampleWeightedQCOM = 4484,
  TextureBoxFilterQCOM = 4485,
  TextureBlockMatchQCOM = 4486,
  TileShadingQCOM = 4495,
  CooperativeMatrixConversionQCOM = 4496,
  TextureBlockMatch2QCOM = 4498,
  MultipleWaitQueuesQCOM = 4539,
  ImageGatherLinearQCOM = 4543,
  ImageGatherExtendedModesQCOM = 4544,
  Float16ImageAMD = 5008,
  ImageGatherBiasLodAMD = 5009,
  FragmentMaskAMD = 5010,
  StencilExportEXT = 5013,
  ImageReadWriteLodAMD = 5015,
  Int64ImageEXT = 5016,
  ShaderClockKHR = 5055,
  ShaderEnqueueAMDX = 5067,
  QuadControlKHR = 5087,
  Int4TypeINTEL = 5112,
  Int4CooperativeMatrixINTEL = 5114,
  BFloat16TypeKHR = 5116,
  BFloat16DotProductKHR = 5117,
  BFloat16CooperativeMatrixKHR = 5118,
  AbortKHR = 5120,
  DescriptorHeapEXT = 5128,
  ConstantDataKHR = 5146,
  PoisonFreezeKHR = 5156,
  WeakLinkageAMD = 5181,
  SampleMaskOverrideCoverageNV = 5249,
  GeometryShaderPassthroughNV = 5251,
  ShaderViewportIndexLayerEXT = 5254,
  ShaderViewportIndexLayerNV = 5254,
  ShaderViewportMaskNV = 5255,
  ShaderStereoViewNV = 5259,
  PerViewAttributesNV = 5260,
  FragmentFullyCoveredEXT = 5265,
  MeshShadingNV = 5266,
  ImageFootprintNV = 5282,
  MeshShadingEXT = 5283,
  FragmentBarycentricKHR = 5284,
  FragmentBarycentricNV = 5284,
  ComputeDerivativeGroupQuadsKHR = 5288,
  ComputeDerivativeGroupQuadsNV = 5288,
  FragmentDensityEXT = 5291,
  ShadingRateNV = 5291,
  GroupNonUniformPartitionedEXT = 5297,
  GroupNonUniformPartitionedNV = 5297,
  ShaderNonUniform = 5301,
  ShaderNonUniformEXT = 5301,
  RuntimeDescriptorArray = 5302,
  RuntimeDescriptorArrayEXT = 5302,
  InputAttachmentArrayDynamicIndexing = 5303,
  InputAttachmentArrayDynamicIndexingEXT = 5303,
  UniformTexelBufferArrayDynamicIndexing = 5304,
  UniformTexelBufferArrayDynamicIndexingEXT = 5304,
  StorageTexelBufferArrayDynamicIndexing = 5305,
  StorageTexelBufferArrayDynamicIndexingEXT = 5305,
  UniformBufferArrayNonUniformIndexing = 5306,
  UniformBufferArrayNonUniformIndexingEXT = 5306,
  SampledImageArrayNonUniformIndexing = 5307,
  SampledImageArrayNonUniformIndexingEXT = 5307,
  StorageBufferArrayNonUniformIndexing = 5308,
  StorageBufferArrayNonUniformIndexingEXT = 5308,
  StorageImageArrayNonUniformIndexing = 5309,
  StorageImageArrayNonUniformIndexingEXT = 5309,
  InputAttachmentArrayNonUniformIndexing = 5310,
  InputAttachmentArrayNonUniformIndexingEXT = 5310,
  UniformTexelBufferArrayNonUniformIndexing = 5311,
  UniformTexelBufferArrayNonUniformIndexingEXT = 5311,
  StorageTexelBufferArrayNonUniformIndexing = 5312,
  StorageTexelBufferArrayNonUniformIndexingEXT = 5312,
  RayTracingPositionFetchKHR = 5336,
  RayTracingNV = 5340,
  RayTracingMotionBlurNV = 5341,
  VulkanMemoryModel = 5345,
  VulkanMemoryModelKHR = 5345,
  VulkanMemoryModelDeviceScope = 5346,
  VulkanMemoryModelDeviceScopeKHR = 5346,
  PhysicalStorageBufferAddresses = 5347,
  PhysicalStorageBufferAddressesEXT = 5347,
  ComputeDerivativeGroupLinearKHR = 5350,
  ComputeDerivativeGroupLinearNV = 5350,
  RayTracingProvisionalKHR = 5353,
  CooperativeMatrixNV = 5357,
  FragmentShaderSampleInterlockEXT = 5363,
  FragmentShaderShadingRateInterlockEXT = 5372,
  ShaderSMBuiltinsNV = 5373,
  FragmentShaderPixelInterlockEXT = 5378,
  DemoteToHelperInvocation = 5379,
  DemoteToHelperInvocationEXT = 5379,
  DisplacementMicromapNV = 5380,
  RayTracingOpacityMicromapEXT = 5381,
  RayTracingOpacityMicromapKHR = 5381,
  ShaderInvocationReorderNV = 5383,
  ShaderInvocationReorderEXT = 5388,
  BindlessTextureNV = 5390,
  RayQueryPositionFetchKHR = 5391,
  CooperativeVectorNV = 5394,
  AtomicFloat16VectorNV = 5404,
  RayTracingDisplacementMicromapNV = 5409,
  RawAccessChainsNV = 5414,
  RayTracingSpheresGeometryNV = 5418,
  RayTracingLinearSweptSpheresGeometryNV = 5419,
  PushConstantBanksNV = 5423,
  LongVectorEXT = 5425,
  Shader64BitIndexingEXT = 5426,
  CooperativeMatrixReductionsNV = 5430,
  CooperativeMatrixConversionsNV = 5431,
  CooperativeMatrixPerElementOperationsNV = 5432,
  CooperativeMatrixTensorAddressingNV = 5433,
  CooperativeMatrixBlockLoadsNV = 5434,
  CooperativeVectorTrainingNV = 5435,
  RayTracingClusterAccelerationStructureNV = 5437,
  TensorAddressingNV = 5439,
  CooperativeMatrixDecodeVectorNV = 5447,
  SubgroupShuffleINTEL = 5568,
  SubgroupBufferBlockIOINTEL = 5569,
  SubgroupImageBlockIOINTEL = 5570,
  SubgroupImageMediaBlockIOINTEL = 5579,
  RoundToInfinityINTEL = 5582,
  FloatingPointModeINTEL = 5583,
  IntegerFunctions2INTEL = 5584,
  FunctionPointersINTEL = 5603,
  IndirectReferencesINTEL = 5604,
  AsmINTEL = 5606,
  AtomicFloat32MinMaxEXT = 5612,
  AtomicFloat64MinMaxEXT = 5613,
  AtomicFloat16MinMaxEXT = 5616,
  VectorComputeINTEL = 5617,
  VectorAnyINTEL = 5619,
  ExpectAssumeKHR = 5629,
  SubgroupAvcMotionEstimationINTEL = 5696,
  SubgroupAvcMotionEstimationIntraINTEL = 5697,
  SubgroupAvcMotionEstimationChromaINTEL = 5698,
  VariableLengthArrayINTEL = 5817,
  FunctionFloatControlINTEL = 5821,
  FPGAMemoryAttributesALTERA = 5824,
  FPGAMemoryAttributesINTEL = 5824,
  FPFastMathModeINTEL = 5837,
  ArbitraryPrecisionIntegersALTERA = 5844,
  ArbitraryPrecisionIntegersINTEL = 5844,
  ArbitraryPrecisionFloatingPointALTERA = 5845,
  ArbitraryPrecisionFloatingPointINTEL = 5845,
  UnstructuredLoopControlsINTEL = 5886,
  FPGALoopControlsALTERA = 5888,
  FPGALoopControlsINTEL = 5888,
  KernelAttributesINTEL = 5892,
  FPGAKernelAttributesINTEL = 5897,
  FPGAMemoryAccessesALTERA = 5898,
  FPGAMemoryAccessesINTEL = 5898,
  FPGAClusterAttributesALTERA = 5904,
  FPGAClusterAttributesINTEL = 5904,
  LoopFuseALTERA = 5906,
  LoopFuseINTEL = 5906,
  FPGADSPControlALTERA = 5908,
  FPGADSPControlINTEL = 5908,
  MemoryAccessAliasingINTEL = 5910,
  FPGAInvocationPipeliningAttributesALTERA = 5916,
  FPGAInvocationPipeliningAttributesINTEL = 5916,
  FPGABufferLocationALTERA = 5920,
  FPGABufferLocationINTEL = 5920,
  ArbitraryPrecisionFixedPointALTERA = 5922,
  ArbitraryPrecisionFixedPointINTEL = 5922,
  USMStorageClassesALTERA = 5935,
  USMStorageClassesINTEL = 5935,
  RuntimeAlignedAttributeALTERA = 5939,
  RuntimeAlignedAttributeINTEL = 5939,
  IOPipesALTERA = 5943,
  IOPipesINTEL = 5943,
  BlockingPipesALTERA = 5945,
  BlockingPipesINTEL = 5945,
  FPGARegALTERA = 5948,
  FPGARegINTEL = 5948,
  DotProductInputAll = 6016,
  DotProductInputAllKHR = 6016,
  DotProductInput4x8Bit = 6017,
  DotProductInput4x8BitKHR = 6017,
  DotProductInput4x8BitPacked = 6018,
  DotProductInput4x8BitPackedKHR = 6018,
  DotProduct = 6019,
  DotProductKHR = 6019,
  RayCullMaskKHR = 6020,
  CooperativeMatrixKHR = 6022,
  ReplicatedCompositesEXT = 6024,
  BitInstructions = 6025,
  GroupNonUniformRotateKHR = 6026,
  FloatControls2 = 6029,
  FMAKHR = 6030,
  RayTracingOpacityMicromapExecutionModeKHR = 6032,
  AtomicFloat32AddEXT = 6033,
  AtomicFloat64AddEXT = 6034,
  LongCompositesINTEL = 6089,
  OptNoneEXT = 6094,
  OptNoneINTEL = 6094,
  AtomicFloat16AddEXT = 6095,
  DebugInfoModuleINTEL = 6114,
  BFloat16ConversionINTEL = 6115,
  SplitBarrierEXT = 6141,
  SplitBarrierINTEL = 6141,
  ArithmeticFenceEXT = 6144,
  FPGAClusterAttributesV2ALTERA = 6150,
  FPGAClusterAttributesV2INTEL = 6150,
  FPGAKernelAttributesv2INTEL = 6161,
  TaskSequenceALTERA = 6162,
  TaskSequenceINTEL = 6162,
  FPMaxErrorINTEL = 6169,
  FPGALatencyControlALTERA = 6171,
  FPGALatencyControlINTEL = 6171,
  FPGAArgumentInterfacesALTERA = 6174,
  FPGAArgumentInterfacesINTEL = 6174,
  GlobalVariableHostAccessINTEL = 6187,
  GlobalVariableFPGADecorationsALTERA = 6189,
  GlobalVariableFPGADecorationsINTEL = 6189,
  SubgroupBufferPrefetchINTEL = 6220,
  Subgroup2DBlockIOINTEL = 6228,
  Subgroup2DBlockTransformINTEL = 6229,
  Subgroup2DBlockTransposeINTEL = 6230,
  SubgroupMatrixMultiplyAccumulateINTEL = 6236,
  TernaryBitwiseFunctionINTEL = 6241,
  UntypedVariableLengthArrayINTEL = 6243,
  SpecConditionalINTEL = 6245,
  FunctionVariantsINTEL = 6246,
  PredicatedIOINTEL = 6257,
  RoundedDivideSqrtINTEL = 6265,
  GroupUniformArithmeticKHR = 6400,
  TensorFloat32RoundingINTEL = 6425,
  MaskedGatherScatterINTEL = 6427,
  CacheControlsINTEL = 6441,
  RegisterLimitsINTEL = 6460,
  BindlessImagesINTEL = 6528,
  DotProductFloat16AccFloat32VALVE = 6912,
  DotProductFloat16AccFloat16VALVE = 6913,
  DotProductBFloat16AccVALVE = 6914,
  DotProductFloat8AccFloat32VALVE = 6915,
  IntrinsicSAMSUNG = 7041,
  Max = 0x7fffffff,
}

SpvSourceLanguage :: enum u32 {
  Unknown = 0,
  ESSL = 1,
  GLSL = 2,
  OpenCL_C = 3,
  OpenCL_CPP = 4,
  HLSL = 5,
  CPP_for_OpenCL = 6,
  SYCL = 7,
  HERO_C = 8,
  NZSL = 9,
  WGSL = 10,
  Slang = 11,
  Zig = 12,
  Rust = 13,
  Pred = 14,
  ApilaJai = 15,
  Max = 0x7fffffff,
}


/// ================================



/*! @enum SpvReflectResult

*/
Result :: enum i32 {
	SUCCESS                                    = 0,
	NOT_READY                                  = 1,
	ERROR_PARSE_FAILED                         = 2,
	ERROR_ALLOC_FAILED                         = 3,
	ERROR_RANGE_EXCEEDED                       = 4,
	ERROR_NULL_POINTER                         = 5,
	ERROR_INTERNAL_ERROR                       = 6,
	ERROR_COUNT_MISMATCH                       = 7,
	ERROR_ELEMENT_NOT_FOUND                    = 8,
	ERROR_SPIRV_INVALID_CODE_SIZE              = 9,
	ERROR_SPIRV_INVALID_MAGIC_NUMBER           = 10,
	ERROR_SPIRV_UNEXPECTED_EOF                 = 11,
	ERROR_SPIRV_INVALID_ID_REFERENCE           = 12,
	ERROR_SPIRV_SET_NUMBER_OVERFLOW            = 13,
	ERROR_SPIRV_INVALID_STORAGE_CLASS          = 14,
	ERROR_SPIRV_RECURSION                      = 15,
	ERROR_SPIRV_INVALID_INSTRUCTION            = 16,
	ERROR_SPIRV_UNEXPECTED_BLOCK_DATA          = 17,
	ERROR_SPIRV_INVALID_BLOCK_MEMBER_REFERENCE = 18,
	ERROR_SPIRV_INVALID_ENTRY_POINT            = 19,
	ERROR_SPIRV_INVALID_EXECUTION_MODE         = 20,
	ERROR_SPIRV_MAX_RECURSIVE_EXCEEDED         = 21,
}

/*! @enum SpvReflectModuleFlagBits

SPV_REFLECT_MODULE_FLAG_NO_COPY - Disables copying of SPIR-V code
when a SPIRV-Reflect shader module is created. It is the
responsibility of the calling program to ensure that the pointer
remains valid and the memory it's pointing to is not freed while
SPIRV-Reflect operations are taking place. Freeing the backing
memory will cause undefined behavior or most likely a crash.
This is flag is intended for cases where the memory overhead of
storing the copied SPIR-V is undesirable.

*/
ModuleFlagBits :: enum i32 {
	NE    = 0,
	_COPY = 1,
}

ModuleFlags :: u32

/*! @enum SpvReflectTypeFlagBits

*/
TypeFlagBits :: enum i32 {
	UNDEFINED                       = 0,
	VOID                            = 1,
	BOOL                            = 2,
	INT                             = 4,
	FLOAT                           = 8,
	VECTOR                          = 256,
	MATRIX                          = 512,
	EXTERNAL_IMAGE                  = 65536,
	EXTERNAL_SAMPLER                = 131072,
	EXTERNAL_SAMPLED_IMAGE          = 262144,
	EXTERNAL_BLOCK                  = 524288,
	EXTERNAL_ACCELERATION_STRUCTURE = 1048576,
	EXTERNAL_MASK                   = 16711680,
	STRUCT                          = 268435456,
	ARRAY                           = 536870912,
	REF                             = 1073741824,
}

TypeFlags :: u32

/*! @enum SpvReflectDecorationBits

NOTE: HLSL row_major and column_major decorations are reversed
in SPIR-V. Meaning that matrices declrations with row_major
will get reflected as column_major and vice versa. The
row and column decorations get appied during the compilation.
SPIRV-Reflect reads the data as is and does not make any
attempt to correct it to match what's in the source.

The Patch, PerVertex, and PerTask are used for Interface
variables that can have array

*/
DecorationFlagBits :: enum i32 {
	NONE                = 0,
	BLOCK               = 1,
	BUFFER_BLOCK        = 2,
	ROW_MAJOR           = 4,
	COLUMN_MAJOR        = 8,
	BUILT_IN            = 16,
	NOPERSPECTIVE       = 32,
	FLAT                = 64,
	NON_WRITABLE        = 128,
	RELAXED_PRECISION   = 256,
	NON_READABLE        = 512,
	PATCH               = 1024,
	PER_VERTEX          = 2048,
	PER_TASK            = 4096,
	WEIGHT_TEXTURE      = 8192,
	BLOCK_MATCH_TEXTURE = 16384,
}

DecorationFlags :: u32

// Based of SPV_GOOGLE_user_type
UserType :: enum i32 {
	INVALID                                = 0,
	CBUFFER                                = 1,
	TBUFFER                                = 2,
	APPEND_STRUCTURED_BUFFER               = 3,
	BUFFER                                 = 4,
	BYTE_ADDRESS_BUFFER                    = 5,
	CONSTANT_BUFFER                        = 6,
	CONSUME_STRUCTURED_BUFFER              = 7,
	INPUT_PATCH                            = 8,
	OUTPUT_PATCH                           = 9,
	RASTERIZER_ORDERED_BUFFER              = 10,
	RASTERIZER_ORDERED_BYTE_ADDRESS_BUFFER = 11,
	RASTERIZER_ORDERED_STRUCTURED_BUFFER   = 12,
	RASTERIZER_ORDERED_TEXTURE_1D          = 13,
	RASTERIZER_ORDERED_TEXTURE_1D_ARRAY    = 14,
	RASTERIZER_ORDERED_TEXTURE_2D          = 15,
	RASTERIZER_ORDERED_TEXTURE_2D_ARRAY    = 16,
	RASTERIZER_ORDERED_TEXTURE_3D          = 17,
	RAYTRACING_ACCELERATION_STRUCTURE      = 18,
	RW_BUFFER                              = 19,
	RW_BYTE_ADDRESS_BUFFER                 = 20,
	RW_STRUCTURED_BUFFER                   = 21,
	RW_TEXTURE_1D                          = 22,
	RW_TEXTURE_1D_ARRAY                    = 23,
	RW_TEXTURE_2D                          = 24,
	RW_TEXTURE_2D_ARRAY                    = 25,
	RW_TEXTURE_3D                          = 26,
	STRUCTURED_BUFFER                      = 27,
	SUBPASS_INPUT                          = 28,
	SUBPASS_INPUT_MS                       = 29,
	TEXTURE_1D                             = 30,
	TEXTURE_1D_ARRAY                       = 31,
	TEXTURE_2D                             = 32,
	TEXTURE_2D_ARRAY                       = 33,
	TEXTURE_2DMS                           = 34,
	TEXTURE_2DMS_ARRAY                     = 35,
	TEXTURE_3D                             = 36,
	TEXTURE_BUFFER                         = 37,
	TEXTURE_CUBE                           = 38,
	TEXTURE_CUBE_ARRAY                     = 39,
}

/*! @enum SpvReflectResourceType

*/
ResourceType :: enum i32 {
	UNDEFINED = 0,
	SAMPLER   = 1,
	CBV       = 2,
	SRV       = 4,
	UAV       = 8,
}

/*! @enum SpvReflectFormat

*/
Format :: enum i32 {
	UNDEFINED           = 0,   // = VK_FORMAT_UNDEFINED
	R16_UINT            = 74,  // = VK_FORMAT_R16_UINT
	R16_SINT            = 75,  // = VK_FORMAT_R16_SINT
	R16_SFLOAT          = 76,  // = VK_FORMAT_R16_SFLOAT
	R16G16_UINT         = 81,  // = VK_FORMAT_R16G16_UINT
	R16G16_SINT         = 82,  // = VK_FORMAT_R16G16_SINT
	R16G16_SFLOAT       = 83,  // = VK_FORMAT_R16G16_SFLOAT
	R16G16B16_UINT      = 88,  // = VK_FORMAT_R16G16B16_UINT
	R16G16B16_SINT      = 89,  // = VK_FORMAT_R16G16B16_SINT
	R16G16B16_SFLOAT    = 90,  // = VK_FORMAT_R16G16B16_SFLOAT
	R16G16B16A16_UINT   = 95,  // = VK_FORMAT_R16G16B16A16_UINT
	R16G16B16A16_SINT   = 96,  // = VK_FORMAT_R16G16B16A16_SINT
	R16G16B16A16_SFLOAT = 97,  // = VK_FORMAT_R16G16B16A16_SFLOAT
	R32_UINT            = 98,  // = VK_FORMAT_R32_UINT
	R32_SINT            = 99,  // = VK_FORMAT_R32_SINT
	R32_SFLOAT          = 100, // = VK_FORMAT_R32_SFLOAT
	R32G32_UINT         = 101, // = VK_FORMAT_R32G32_UINT
	R32G32_SINT         = 102, // = VK_FORMAT_R32G32_SINT
	R32G32_SFLOAT       = 103, // = VK_FORMAT_R32G32_SFLOAT
	R32G32B32_UINT      = 104, // = VK_FORMAT_R32G32B32_UINT
	R32G32B32_SINT      = 105, // = VK_FORMAT_R32G32B32_SINT
	R32G32B32_SFLOAT    = 106, // = VK_FORMAT_R32G32B32_SFLOAT
	R32G32B32A32_UINT   = 107, // = VK_FORMAT_R32G32B32A32_UINT
	R32G32B32A32_SINT   = 108, // = VK_FORMAT_R32G32B32A32_SINT
	R32G32B32A32_SFLOAT = 109, // = VK_FORMAT_R32G32B32A32_SFLOAT
	R64_UINT            = 110, // = VK_FORMAT_R64_UINT
	R64_SINT            = 111, // = VK_FORMAT_R64_SINT
	R64_SFLOAT          = 112, // = VK_FORMAT_R64_SFLOAT
	R64G64_UINT         = 113, // = VK_FORMAT_R64G64_UINT
	R64G64_SINT         = 114, // = VK_FORMAT_R64G64_SINT
	R64G64_SFLOAT       = 115, // = VK_FORMAT_R64G64_SFLOAT
	R64G64B64_UINT      = 116, // = VK_FORMAT_R64G64B64_UINT
	R64G64B64_SINT      = 117, // = VK_FORMAT_R64G64B64_SINT
	R64G64B64_SFLOAT    = 118, // = VK_FORMAT_R64G64B64_SFLOAT
	R64G64B64A64_UINT   = 119, // = VK_FORMAT_R64G64B64A64_UINT
	R64G64B64A64_SINT   = 120, // = VK_FORMAT_R64G64B64A64_SINT
	R64G64B64A64_SFLOAT = 121, // = VK_FORMAT_R64G64B64A64_SFLOAT
}

/*! @enum SpvReflectVariableFlagBits

*/
VariableFlagBits :: enum i32 {
	NONE                  = 0,
	UNUSED                = 1,

	// If variable points to a copy of the PhysicalStorageBuffer struct
	PHYSICAL_POINTER_COPY = 2,
}

VariableFlags :: u32

/*! @enum SpvReflectDescriptorType

*/
DescriptorType :: enum i32 {
	SAMPLER                    = 0,          // = VK_DESCRIPTOR_TYPE_SAMPLER
	COMBINED_IMAGE_SAMPLER     = 1,          // = VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER
	SAMPLED_IMAGE              = 2,          // = VK_DESCRIPTOR_TYPE_SAMPLED_IMAGE
	STORAGE_IMAGE              = 3,          // = VK_DESCRIPTOR_TYPE_STORAGE_IMAGE
	UNIFORM_TEXEL_BUFFER       = 4,          // = VK_DESCRIPTOR_TYPE_UNIFORM_TEXEL_BUFFER
	STORAGE_TEXEL_BUFFER       = 5,          // = VK_DESCRIPTOR_TYPE_STORAGE_TEXEL_BUFFER
	UNIFORM_BUFFER             = 6,          // = VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER
	STORAGE_BUFFER             = 7,          // = VK_DESCRIPTOR_TYPE_STORAGE_BUFFER
	UNIFORM_BUFFER_DYNAMIC     = 8,          // = VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER_DYNAMIC
	STORAGE_BUFFER_DYNAMIC     = 9,          // = VK_DESCRIPTOR_TYPE_STORAGE_BUFFER_DYNAMIC
	INPUT_ATTACHMENT           = 10,         // = VK_DESCRIPTOR_TYPE_INPUT_ATTACHMENT
	ACCELERATION_STRUCTURE_KHR = 1000150000, // = VK_DESCRIPTOR_TYPE_ACCELERATION_STRUCTURE_KHR
}

/*! @enum SpvReflectShaderStageFlagBits

*/
ShaderStageFlagBits :: enum i32 {
	VERTEX_BIT                  = 1,    // = VK_SHADER_STAGE_VERTEX_BIT
	TESSELLATION_CONTROL_BIT    = 2,    // = VK_SHADER_STAGE_TESSELLATION_CONTROL_BIT
	TESSELLATION_EVALUATION_BIT = 4,    // = VK_SHADER_STAGE_TESSELLATION_EVALUATION_BIT
	GEOMETRY_BIT                = 8,    // = VK_SHADER_STAGE_GEOMETRY_BIT
	FRAGMENT_BIT                = 16,   // = VK_SHADER_STAGE_FRAGMENT_BIT
	COMPUTE_BIT                 = 32,   // = VK_SHADER_STAGE_COMPUTE_BIT
	TASK_BIT_NV                 = 64,   // = VK_SHADER_STAGE_TASK_BIT_NV
	TASK_BIT_EXT                = 64,   // = VK_SHADER_STAGE_CALLABLE_BIT_EXT
	MESH_BIT_NV                 = 128,  // = VK_SHADER_STAGE_MESH_BIT_NV
	MESH_BIT_EXT                = 128,  // = VK_SHADER_STAGE_CALLABLE_BIT_EXT
	RAYGEN_BIT_KHR              = 256,  // = VK_SHADER_STAGE_RAYGEN_BIT_KHR
	ANY_HIT_BIT_KHR             = 512,  // = VK_SHADER_STAGE_ANY_HIT_BIT_KHR
	CLOSEST_HIT_BIT_KHR         = 1024, // = VK_SHADER_STAGE_CLOSEST_HIT_BIT_KHR
	MISS_BIT_KHR                = 2048, // = VK_SHADER_STAGE_MISS_BIT_KHR
	INTERSECTION_BIT_KHR        = 4096, // = VK_SHADER_STAGE_INTERSECTION_BIT_KHR
	CALLABLE_BIT_KHR            = 8192, // = VK_SHADER_STAGE_CALLABLE_BIT_KHR
}

/*! @enum SpvReflectGenerator

*/
Generator :: enum i32 {
	KHRONOS_LLVM_SPIRV_TRANSLATOR         = 6,
	KHRONOS_SPIRV_TOOLS_ASSEMBLER         = 7,
	KHRONOS_GLSLANG_REFERENCE_FRONT_END   = 8,
	GOOGLE_SHADERC_OVER_GLSLANG           = 13,
	GOOGLE_SPIREGG                        = 14,
	GOOGLE_RSPIRV                         = 15,
	X_LEGEND_MESA_MESAIR_SPIRV_TRANSLATOR = 16,
	KHRONOS_SPIRV_TOOLS_LINKER            = 17,
	WINE_VKD3D_SHADER_COMPILER            = 18,
	CLAY_CLAY_SHADER_COMPILER             = 19,
	SLANG_SHADER_COMPILER                 = 40,
}

SPV_REFLECT_MAX_ARRAY_DIMS             :: 32
SPV_REFLECT_MAX_DESCRIPTOR_SETS        :: 64
SPV_REFLECT_BINDING_NUMBER_DONT_CHANGE :: -1
SPV_REFLECT_SET_NUMBER_DONT_CHANGE     :: -1

NumericTraits :: struct {
	scalar:  Scalar,
	vector:  Vector,
	_matrix: Matrix,
}

Scalar :: struct {
	width:      u32,
	signedness: u32,
}

Vector :: struct {
	component_count: u32,
}

Matrix :: struct {
	column_count: u32,
	row_count:    u32,
	stride:       u32, // Measured in bytes
}

ImageTraits :: struct {
	dim:          SpvDim,
	depth:        u32,
	arrayed:      u32,
	ms:           u32, // 0: single-sampled; 1: multisampled
	sampled:      u32,
	image_format: SpvImageFormat,
}

ArrayDimType :: enum i32 {
	SPV_REFLECT_ARRAY_DIM_RUNTIME = 0, // OpTypeRuntimeArray
}

ArrayTraits :: struct {
	dims_count: u32,

	// Each entry is either:
	// - specialization constant dimension
	// - OpTypeRuntimeArray
	// - the array length otherwise
	dims: [SPV_REFLECT_MAX_ARRAY_DIMS]u32,

	// Stores Ids for dimensions that are specialization constants
	spec_constant_op_ids: [SPV_REFLECT_MAX_ARRAY_DIMS]u32,
	stride:               u32, // Measured in bytes
}

BindingArrayTraits :: struct {
	dims_count: u32,
	dims:       [SPV_REFLECT_MAX_ARRAY_DIMS]u32,
}

/*! @struct SpvReflectTypeDescription
@brief Information about an OpType* instruction
*/
TypeDescription :: struct {
	id:        u32,
	op:        SpvOp,
	type_name: cstring,

	// Non-NULL if type is member of a struct
	struct_member_name: cstring,

	// The storage class (SpvStorageClass) if the type, and -1 if it does not have a storage class.
	storage_class:    i32,
	type_flags:       TypeFlags,
	decoration_flags: DecorationFlags,
	traits:           Traits,

	// If underlying type is a struct (ex. array of structs)
	// this gives access to the OpTypeStruct
	struct_type_description: ^TypeDescription,

	// Some pointers to SpvReflectTypeDescription are really
	// just copies of another reference to the same OpType
	copied: u32,

	// @deprecated use struct_type_description instead
	member_count: u32,

	// @deprecated use struct_type_description instead
	members: ^TypeDescription,
}

Traits :: struct {
	numeric: NumericTraits,
	image:   ImageTraits,
	array:   ArrayTraits,
}

/*! @struct SpvReflectInterfaceVariable
@brief The OpVariable that is either an Input or Output to the module
*/
InterfaceVariable :: struct {
	spirv_id:         u32,
	name:             cstring,
	location:         u32,
	component:        u32,
	storage_class:    SpvStorageClass,
	semantic:         cstring,
	decoration_flags: DecorationFlags,

	// The builtin id (SpvBuiltIn) if the variable is a builtin, and -1 otherwise.
	built_in:     i32,
	numeric:      NumericTraits,
	array:        ArrayTraits,
	member_count: u32,
	members:      ^InterfaceVariable,
	format:       Format,

	// NOTE: SPIR-V shares type references for variables
	//       that have the same underlying type. This means
	//       that the same type name will appear for multiple
	//       variables.
	type_description: ^TypeDescription,

	word_offset: struct {
		location: u32,
	},
}

/*! @struct SpvReflectBlockVariable

*/
BlockVariable :: struct {
	spirv_id: u32,
	name:     cstring,

	// For Push Constants, this is the lowest offset of all memebers
	offset:           u32, // Measured in bytes
	absolute_offset:  u32, // Measured in bytes
	size:             u32, // Measured in bytes
	padded_size:      u32, // Measured in bytes
	decoration_flags: DecorationFlags,
	numeric:          NumericTraits,
	array:            ArrayTraits,
	flags:            VariableFlags,
	member_count:     u32,
	members:          ^BlockVariable,
	type_description: ^TypeDescription,

	word_offset: struct {
		offset: u32,
	},
}

/*! @struct SpvReflectDescriptorBinding

*/
DescriptorBinding :: struct {
	spirv_id:                         u32,
	name:                             cstring,
	binding:                          u32,
	input_attachment_index:           u32,
	set:                              u32,
	descriptor_type:                  DescriptorType,
	resource_type:                    ResourceType,
	image:                            ImageTraits,
	block:                            BlockVariable,
	array:                            BindingArrayTraits,
	count:                            u32,
	accessed:                         u32,
	uav_counter_id:                   u32,
	uav_counter_binding:              ^DescriptorBinding,
	byte_address_buffer_offset_count: u32,
	byte_address_buffer_offsets:      ^u32,
	type_description:                 ^TypeDescription,

	word_offset: struct {
		binding: u32,
		set:     u32,
	},

	decoration_flags: DecorationFlags,

	// Requires SPV_GOOGLE_user_type
	user_type: UserType,
}

/*! @struct SpvReflectDescriptorSet

*/
DescriptorSet :: struct {
	set:           u32,
	binding_count: u32,
	bindings:      ^^DescriptorBinding,
}

ExecutionModeValue :: enum i32 {
	SPV_REFLECT_EXECUTION_MODE_SPEC_CONSTANT = -1, // specialization constant
}

/*! @struct SpvReflectEntryPointResourceHeapAccess
@brief One distinct resource-heap access pattern (OpUntypedAccessChainKHR
element type + stride) reachable from this entry point.
*/
EntryPointResourceHeapAccess :: struct {
	heap_name:             cstring,
	runtime_array_type_id: u32,
	stride:                u32, // UINT32_MAX when not specified by shader (e.g. ArrayStride from OpConstantSizeOfEXT) or could not be resolved
	descriptor_type:       DescriptorType,
	type_description:      ^TypeDescription,
}

/*! @struct SpvReflectEntryPointSamplerHeapAccess
@brief One distinct sampler-heap access pattern reachable from this entry
point (usually at most one).
*/
EntryPointSamplerHeapAccess :: struct {
	heap_name:             cstring,
	runtime_array_type_id: u32,
	stride:                u32, // UINT32_MAX when not specified by shader (e.g. ArrayStride from OpConstantSizeOfEXT) or could not be resolved
	type_description:      ^TypeDescription,
}

/*! @struct SpvReflectEntryPoint

*/
EntryPoint :: struct {
	name:                     cstring,
	id:                       u32,
	spirv_execution_model:    SpvExecutionModel,
	shader_stage:             ShaderStageFlagBits,
	input_variable_count:     u32,
	input_variables:          ^^InterfaceVariable,
	output_variable_count:    u32,
	output_variables:         ^^InterfaceVariable,
	interface_variable_count: u32,
	interface_variables:      ^InterfaceVariable,
	descriptor_set_count:     u32,
	descriptor_sets:          ^DescriptorSet,
	used_uniform_count:       u32,
	used_uniforms:            ^u32,
	used_push_constant_count: u32,
	used_push_constants:      ^u32,
	execution_mode_count:     u32,
	execution_modes:          ^SpvExecutionMode,
	local_size:               LocalSize,
	invocations:              u32, // valid for geometry
	output_vertices:          u32, // valid for geometry, tesselation

	// SPV_EXT_descriptor_heap: distinct heap access patterns reachable from this
	// entry point's static call graph. Each entry corresponds to a unique
	// (heap variable, OpUntypedAccessChainKHR Data Type) pair.
	resource_heap_access_count: u32,
	resource_heap_accesses:     ^EntryPointResourceHeapAccess,
	sampler_heap_access_count:  u32,
	sampler_heap_accesses:      ^EntryPointSamplerHeapAccess,
}

LocalSize :: struct {
	x: u32,
	y: u32,
	z: u32,
}

/*! @struct SpvReflectCapability

*/
Capability :: struct {
	value:       SpvCapability,
	word_offset: u32,
}

/*! @struct SpvReflectSpecId

*/
SpecializationConstant :: struct {
	spirv_id:         u32,
	constant_id:      u32,
	name:             cstring,
	type_description: ^TypeDescription,

	// Size of the default value in bytes (always a multiple of 4).
	// Will be 4 for 8/16/32-bit constants and 8 for 64-bit constants.
	default_value_size: u32,

	// Pointer to the raw default value data.
	// The interpretation of this data depends on type_description->op:
	// - SpvOpSpecConstantTrue:  size = 4, data = uint32_t(1)
	// - SpvOpSpecConstantFalse: size = 4, data = uint32_t(0)
	// - SpvOpSpecConstant:      data contains the bit pattern of the default value
	//   * The type will be a scalar integer or float.
	//   * Types 32 bits wide or smaller take one word.
	//   * Larger types take multiple words, with low-order words appearing first.
	default_value: rawptr,
}

/*! @struct SpvReflectShaderModule

*/
ShaderModule :: struct {
	generator:                 Generator,
	entry_point_name:          cstring,
	entry_point_id:            u32,
	entry_point_count:         u32,
	entry_points:              ^EntryPoint,
	source_language:           SpvSourceLanguage,
	source_language_version:   u32,
	source_file:               cstring,
	source_source:             cstring,
	capability_count:          u32,
	capabilities:              ^Capability,
	spirv_execution_model:     SpvExecutionModel,                 // Uses value(s) from first entry point
	shader_stage:              ShaderStageFlagBits,     // Uses value(s) from first entry point
	descriptor_binding_count:  u32,                               // Uses value(s) from first entry point
	descriptor_bindings:       ^DescriptorBinding,      // Uses value(s) from first entry point
	descriptor_set_count:      u32,                               // Uses value(s) from first entry point
	descriptor_sets:           [64]DescriptorSet,       // Uses value(s) from first entry point
	input_variable_count:      u32,                               // Uses value(s) from first entry point
	input_variables:           ^^InterfaceVariable,     // Uses value(s) from first entry point
	output_variable_count:     u32,                     // Uses value(s) from first entry point
	output_variables:          ^^InterfaceVariable,     // Uses value(s) from first entry point
	interface_variable_count:  u32,                     // Uses value(s) from first entry point
	interface_variables:       ^InterfaceVariable,      // Uses value(s) from first entry point
	push_constant_block_count: u32,                               // Uses value(s) from first entry point
	push_constant_blocks:      ^BlockVariable,          // Uses value(s) from first entry point
	spec_constant_count:       u32,                               // Uses value(s) from first entry point
	spec_constants:            ^SpecializationConstant, // Uses value(s) from first entry point
	_internal:                 ^Internal,
}

Internal :: struct {
	module_flags:           ModuleFlags,
	spirv_size:             c.size_t,
	spirv_code:             ^u32,
	spirv_word_count:       u32,
	type_description_count: c.size_t,
	type_descriptions:      ^TypeDescription,
}

when ODIN_OS == .Windows {
	foreign import spirv_reflect "lib/spirv-reflect-static.lib"
} else {
	// foreign import spirv_reflect "external/spirv_reflect.a"
}

@(default_calling_convention="c")
@(link_prefix = "spvReflect")
foreign spirv_reflect {
	/*! @fn spvReflectCreateShaderModule
	
	@param  size      Size in bytes of SPIR-V code.
	@param  p_code    Pointer to SPIR-V code.
	@param  p_module  Pointer to an instance of SpvReflectShaderModule.
	@return           SPV_REFLECT_RESULT_SUCCESS on success.
	
	*/
	CreateShaderModule :: proc(size: c.size_t, p_code: rawptr, p_module: ^ShaderModule) -> Result ---

	/*! @fn spvReflectCreateShaderModule2
	
	@param  flags     Flags for module creations.
	@param  size      Size in bytes of SPIR-V code.
	@param  p_code    Pointer to SPIR-V code.
	@param  p_module  Pointer to an instance of SpvReflectShaderModule.
	@return           SPV_REFLECT_RESULT_SUCCESS on success.
	
	*/
	CreateShaderModule2 :: proc(flags: ModuleFlags, size: c.size_t, p_code: rawptr, p_module: ^ShaderModule) -> Result ---
	GetShaderModule     :: proc(size: c.size_t, p_code: rawptr, p_module: ^ShaderModule) -> Result ---

	/*! @fn spvReflectDestroyShaderModule
	
	@param  p_module  Pointer to an instance of SpvReflectShaderModule.
	
	*/
	DestroyShaderModule :: proc(p_module: ^ShaderModule) ---

	/*! @fn spvReflectGetCodeSize
	
	@param  p_module  Pointer to an instance of SpvReflectShaderModule.
	@return           Returns the size of the SPIR-V in bytes
	
	*/
	GetCodeSize :: proc(p_module: ^ShaderModule) -> u32 ---

	/*! @fn spvReflectGetCode
	
	@param  p_module  Pointer to an instance of SpvReflectShaderModule.
	@return           Returns a const pointer to the compiled SPIR-V bytecode.
	
	*/
	GetCode :: proc(p_module: ^ShaderModule) -> ^u32 ---

	/*! @fn spvReflectGetEntryPoint
	
	@param  p_module     Pointer to an instance of SpvReflectShaderModule.
	@param  entry_point  Name of the requested entry point.
	@return              Returns a const pointer to the requested entry point,
	or NULL if it's not found.
	*/
	GetEntryPoint :: proc(p_module: ^ShaderModule, entry_point: cstring) -> ^EntryPoint ---

	/*! @fn spvReflectEnumerateDescriptorBindings
	
	@param  p_module     Pointer to an instance of SpvReflectShaderModule.
	@param  p_count      If pp_bindings is NULL, the module's descriptor binding
	count (across all descriptor sets) will be stored here.
	If pp_bindings is not NULL, *p_count must contain the
	module's descriptor binding count.
	@param  pp_bindings  If NULL, the module's total descriptor binding count
	will be written to *p_count.
	If non-NULL, pp_bindings must point to an array with
	*p_count entries, where pointers to the module's
	descriptor bindings will be written. The caller must not
	free the binding pointers written to this array.
	@return              If successful, returns SPV_REFLECT_RESULT_SUCCESS.
	Otherwise, the error code indicates the cause of the
	failure.
	
	*/
	EnumerateDescriptorBindings :: proc(p_module: ^ShaderModule, p_count: ^u32, pp_bindings: ^^DescriptorBinding) -> Result ---

	/*! @fn spvReflectEnumerateEntryPointDescriptorBindings
	@brief  Creates a listing of all descriptor bindings that are used in the
	static call tree of the given entry point.
	@param  p_module     Pointer to an instance of SpvReflectShaderModule.
	@param  entry_point  The name of the entry point to get the descriptor bindings for.
	@param  p_count      If pp_bindings is NULL, the entry point's descriptor binding
	count (across all descriptor sets) will be stored here.
	If pp_bindings is not NULL, *p_count must contain the
	entry points's descriptor binding count.
	@param  pp_bindings  If NULL, the entry point's total descriptor binding count
	will be written to *p_count.
	If non-NULL, pp_bindings must point to an array with
	*p_count entries, where pointers to the entry point's
	descriptor bindings will be written. The caller must not
	free the binding pointers written to this array.
	@return              If successful, returns SPV_REFLECT_RESULT_SUCCESS.
	Otherwise, the error code indicates the cause of the
	failure.
	
	*/
	EnumerateEntryPointDescriptorBindings :: proc(p_module: ^ShaderModule, entry_point: cstring, p_count: ^u32, pp_bindings: ^^DescriptorBinding) -> Result ---

	/*! @fn spvReflectEnumerateDescriptorSets
	
	@param  p_module  Pointer to an instance of SpvReflectShaderModule.
	@param  p_count   If pp_sets is NULL, the module's descriptor set
	count will be stored here.
	If pp_sets is not NULL, *p_count must contain the
	module's descriptor set count.
	@param  pp_sets   If NULL, the module's total descriptor set count
	will be written to *p_count.
	If non-NULL, pp_sets must point to an array with
	*p_count entries, where pointers to the module's
	descriptor sets will be written. The caller must not
	free the descriptor set pointers written to this array.
	@return           If successful, returns SPV_REFLECT_RESULT_SUCCESS.
	Otherwise, the error code indicates the cause of the
	failure.
	
	*/
	EnumerateDescriptorSets :: proc(p_module: ^ShaderModule, p_count: ^u32, pp_sets: ^^DescriptorSet) -> Result ---

	/*! @fn spvReflectEnumerateEntryPointDescriptorSets
	@brief  Creates a listing of all descriptor sets and their bindings that are
	used in the static call tree of a given entry point.
	@param  p_module    Pointer to an instance of SpvReflectShaderModule.
	@param  entry_point The name of the entry point to get the descriptor bindings for.
	@param  p_count     If pp_sets is NULL, the module's descriptor set
	count will be stored here.
	If pp_sets is not NULL, *p_count must contain the
	module's descriptor set count.
	@param  pp_sets     If NULL, the module's total descriptor set count
	will be written to *p_count.
	If non-NULL, pp_sets must point to an array with
	*p_count entries, where pointers to the module's
	descriptor sets will be written. The caller must not
	free the descriptor set pointers written to this array.
	@return             If successful, returns SPV_REFLECT_RESULT_SUCCESS.
	Otherwise, the error code indicates the cause of the
	failure.
	
	*/
	EnumerateEntryPointDescriptorSets :: proc(p_module: ^ShaderModule, entry_point: cstring, p_count: ^u32, pp_sets: ^^DescriptorSet) -> Result ---

	/*! @fn spvReflectEnumerateInterfaceVariables
	@brief  If the module contains multiple entry points, this will only get
	the interface variables for the first one.
	@param  p_module      Pointer to an instance of SpvReflectShaderModule.
	@param  p_count       If pp_variables is NULL, the module's interface variable
	count will be stored here.
	If pp_variables is not NULL, *p_count must contain
	the module's interface variable count.
	@param  pp_variables  If NULL, the module's interface variable count will be
	written to *p_count.
	If non-NULL, pp_variables must point to an array with
	*p_count entries, where pointers to the module's
	interface variables will be written. The caller must not
	free the interface variables written to this array.
	@return               If successful, returns SPV_REFLECT_RESULT_SUCCESS.
	Otherwise, the error code indicates the cause of the
	failure.
	
	*/
	EnumerateInterfaceVariables :: proc(p_module: ^ShaderModule, p_count: ^u32, pp_variables: ^^InterfaceVariable) -> Result ---

	/*! @fn spvReflectEnumerateEntryPointInterfaceVariables
	@brief  Enumerate the interface variables for a given entry point.
	@param  entry_point The name of the entry point to get the interface variables for.
	@param  p_module      Pointer to an instance of SpvReflectShaderModule.
	@param  p_count       If pp_variables is NULL, the entry point's interface variable
	count will be stored here.
	If pp_variables is not NULL, *p_count must contain
	the entry point's interface variable count.
	@param  pp_variables  If NULL, the entry point's interface variable count will be
	written to *p_count.
	If non-NULL, pp_variables must point to an array with
	*p_count entries, where pointers to the entry point's
	interface variables will be written. The caller must not
	free the interface variables written to this array.
	@return               If successful, returns SPV_REFLECT_RESULT_SUCCESS.
	Otherwise, the error code indicates the cause of the
	failure.
	
	*/
	EnumerateEntryPointInterfaceVariables :: proc(p_module: ^ShaderModule, entry_point: cstring, p_count: ^u32, pp_variables: ^^InterfaceVariable) -> Result ---

	/*! @fn spvReflectEnumerateInputVariables
	@brief  If the module contains multiple entry points, this will only get
	the input variables for the first one.
	@param  p_module      Pointer to an instance of SpvReflectShaderModule.
	@param  p_count       If pp_variables is NULL, the module's input variable
	count will be stored here.
	If pp_variables is not NULL, *p_count must contain
	the module's input variable count.
	@param  pp_variables  If NULL, the module's input variable count will be
	written to *p_count.
	If non-NULL, pp_variables must point to an array with
	*p_count entries, where pointers to the module's
	input variables will be written. The caller must not
	free the interface variables written to this array.
	@return               If successful, returns SPV_REFLECT_RESULT_SUCCESS.
	Otherwise, the error code indicates the cause of the
	failure.
	
	*/
	EnumerateInputVariables :: proc(p_module: ^ShaderModule, p_count: ^u32, pp_variables: ^^InterfaceVariable) -> Result ---

	/*! @fn spvReflectEnumerateEntryPointInputVariables
	@brief  Enumerate the input variables for a given entry point.
	@param  entry_point The name of the entry point to get the input variables for.
	@param  p_module      Pointer to an instance of SpvReflectShaderModule.
	@param  p_count       If pp_variables is NULL, the entry point's input variable
	count will be stored here.
	If pp_variables is not NULL, *p_count must contain
	the entry point's input variable count.
	@param  pp_variables  If NULL, the entry point's input variable count will be
	written to *p_count.
	If non-NULL, pp_variables must point to an array with
	*p_count entries, where pointers to the entry point's
	input variables will be written. The caller must not
	free the interface variables written to this array.
	@return               If successful, returns SPV_REFLECT_RESULT_SUCCESS.
	Otherwise, the error code indicates the cause of the
	failure.
	
	*/
	EnumerateEntryPointInputVariables :: proc(p_module: ^ShaderModule, entry_point: cstring, p_count: ^u32, pp_variables: ^^InterfaceVariable) -> Result ---

	/*! @fn spvReflectEnumerateOutputVariables
	@brief  Note: If the module contains multiple entry points, this will only get
	the output variables for the first one.
	@param  p_module      Pointer to an instance of SpvReflectShaderModule.
	@param  p_count       If pp_variables is NULL, the module's output variable
	count will be stored here.
	If pp_variables is not NULL, *p_count must contain
	the module's output variable count.
	@param  pp_variables  If NULL, the module's output variable count will be
	written to *p_count.
	If non-NULL, pp_variables must point to an array with
	*p_count entries, where pointers to the module's
	output variables will be written. The caller must not
	free the interface variables written to this array.
	@return               If successful, returns SPV_REFLECT_RESULT_SUCCESS.
	Otherwise, the error code indicates the cause of the
	failure.
	
	*/
	EnumerateOutputVariables :: proc(p_module: ^ShaderModule, p_count: ^u32, pp_variables: ^^InterfaceVariable) -> Result ---

	/*! @fn spvReflectEnumerateEntryPointOutputVariables
	@brief  Enumerate the output variables for a given entry point.
	@param  p_module      Pointer to an instance of SpvReflectShaderModule.
	@param  entry_point   The name of the entry point to get the output variables for.
	@param  p_count       If pp_variables is NULL, the entry point's output variable
	count will be stored here.
	If pp_variables is not NULL, *p_count must contain
	the entry point's output variable count.
	@param  pp_variables  If NULL, the entry point's output variable count will be
	written to *p_count.
	If non-NULL, pp_variables must point to an array with
	*p_count entries, where pointers to the entry point's
	output variables will be written. The caller must not
	free the interface variables written to this array.
	@return               If successful, returns SPV_REFLECT_RESULT_SUCCESS.
	Otherwise, the error code indicates the cause of the
	failure.
	
	*/
	EnumerateEntryPointOutputVariables :: proc(p_module: ^ShaderModule, entry_point: cstring, p_count: ^u32, pp_variables: ^^InterfaceVariable) -> Result ---

	/*! @fn spvReflectEnumeratePushConstantBlocks
	@brief  Note: If the module contains multiple entry points, this will only get
	the push constant blocks for the first one.
	@param  p_module   Pointer to an instance of SpvReflectShaderModule.
	@param  p_count    If pp_blocks is NULL, the module's push constant
	block count will be stored here.
	If pp_blocks is not NULL, *p_count must
	contain the module's push constant block count.
	@param  pp_blocks  If NULL, the module's push constant block count
	will be written to *p_count.
	If non-NULL, pp_blocks must point to an
	array with *p_count entries, where pointers to
	the module's push constant blocks will be written.
	The caller must not free the block variables written
	to this array.
	@return            If successful, returns SPV_REFLECT_RESULT_SUCCESS.
	Otherwise, the error code indicates the cause of the
	failure.
	
	*/
	EnumeratePushConstantBlocks :: proc(p_module: ^ShaderModule, p_count: ^u32, pp_blocks: ^^BlockVariable) -> Result ---
	EnumeratePushConstants      :: proc(p_module: ^ShaderModule, p_count: ^u32, pp_blocks: ^^BlockVariable) -> Result ---

	/*! @fn spvReflectEnumerateEntryPointPushConstantBlocks
	@brief  Enumerate the push constant blocks used in the static call tree of a
	given entry point.
	@param  p_module   Pointer to an instance of SpvReflectShaderModule.
	@param  p_count    If pp_blocks is NULL, the entry point's push constant
	block count will be stored here.
	If pp_blocks is not NULL, *p_count must
	contain the entry point's push constant block count.
	@param  pp_blocks  If NULL, the entry point's push constant block count
	will be written to *p_count.
	If non-NULL, pp_blocks must point to an
	array with *p_count entries, where pointers to
	the entry point's push constant blocks will be written.
	The caller must not free the block variables written
	to this array.
	@return            If successful, returns SPV_REFLECT_RESULT_SUCCESS.
	Otherwise, the error code indicates the cause of the
	failure.
	
	*/
	EnumerateEntryPointPushConstantBlocks :: proc(p_module: ^ShaderModule, entry_point: cstring, p_count: ^u32, pp_blocks: ^^BlockVariable) -> Result ---

	/*! @fn spvReflectEnumerateSpecializationConstants
	@param  p_module      Pointer to an instance of SpvReflectShaderModule.
	@param  p_count       If pp_blocks is NULL, the module's specialization constant
	count will be stored here. If pp_blocks is not NULL, *p_count
	must contain the module's specialization constant count.
	@param  pp_constants  If NULL, the module's specialization constant count
	will be written to *p_count. If non-NULL, pp_blocks must
	point to an array with *p_count entries, where pointers to
	the module's specialization constant blocks will be written.
	The caller must not free the  variables written to this array.
	@return               If successful, returns SPV_REFLECT_RESULT_SUCCESS.
	Otherwise, the error code indicates the cause of the failure.
	*/
	EnumerateSpecializationConstants :: proc(p_module: ^ShaderModule, p_count: ^u32, pp_constants: ^^SpecializationConstant) -> Result ---

	/*! @fn spvReflectGetDescriptorBinding
	
	@param  p_module        Pointer to an instance of SpvReflectShaderModule.
	@param  binding_number  The "binding" value of the requested descriptor
	binding.
	@param  set_number      The "set" value of the requested descriptor binding.
	@param  p_result        If successful, SPV_REFLECT_RESULT_SUCCESS will be
	written to *p_result. Otherwise, a error code
	indicating the cause of the failure will be stored
	here.
	@return                 If the module contains a descriptor binding that
	matches the provided [binding_number, set_number]
	values, a pointer to that binding is returned. The
	caller must not free this pointer.
	If no match can be found, or if an unrelated error
	occurs, the return value will be NULL. Detailed
	error results are written to *pResult.
	@note                    If the module contains multiple desriptor bindings
	with the same set and binding numbers, there are
	no guarantees about which binding will be returned.
	
	*/
	GetDescriptorBinding :: proc(p_module: ^ShaderModule, binding_number: u32, set_number: u32, p_result: ^Result) -> ^DescriptorBinding ---

	/*! @fn spvReflectGetEntryPointDescriptorBinding
	@brief  Get the descriptor binding with the given binding number and set
	number that is used in the static call tree of a certain entry
	point.
	@param  p_module        Pointer to an instance of SpvReflectShaderModule.
	@param  entry_point     The entry point to get the binding from.
	@param  binding_number  The "binding" value of the requested descriptor
	binding.
	@param  set_number      The "set" value of the requested descriptor binding.
	@param  p_result        If successful, SPV_REFLECT_RESULT_SUCCESS will be
	written to *p_result. Otherwise, a error code
	indicating the cause of the failure will be stored
	here.
	@return                 If the entry point contains a descriptor binding that
	matches the provided [binding_number, set_number]
	values, a pointer to that binding is returned. The
	caller must not free this pointer.
	If no match can be found, or if an unrelated error
	occurs, the return value will be NULL. Detailed
	error results are written to *pResult.
	@note                    If the entry point contains multiple desriptor bindings
	with the same set and binding numbers, there are
	no guarantees about which binding will be returned.
	
	*/
	GetEntryPointDescriptorBinding :: proc(p_module: ^ShaderModule, entry_point: cstring, binding_number: u32, set_number: u32, p_result: ^Result) -> ^DescriptorBinding ---

	/*! @fn spvReflectGetDescriptorSet
	
	@param  p_module    Pointer to an instance of SpvReflectShaderModule.
	@param  set_number  The "set" value of the requested descriptor set.
	@param  p_result    If successful, SPV_REFLECT_RESULT_SUCCESS will be
	written to *p_result. Otherwise, a error code
	indicating the cause of the failure will be stored
	here.
	@return             If the module contains a descriptor set with the
	provided set_number, a pointer to that set is
	returned. The caller must not free this pointer.
	If no match can be found, or if an unrelated error
	occurs, the return value will be NULL. Detailed
	error results are written to *pResult.
	
	*/
	GetDescriptorSet :: proc(p_module: ^ShaderModule, set_number: u32, p_result: ^Result) -> ^DescriptorSet ---

	/*! @fn spvReflectGetEntryPointDescriptorSet
	
	@param  p_module    Pointer to an instance of SpvReflectShaderModule.
	@param  entry_point The entry point to get the descriptor set from.
	@param  set_number  The "set" value of the requested descriptor set.
	@param  p_result    If successful, SPV_REFLECT_RESULT_SUCCESS will be
	written to *p_result. Otherwise, a error code
	indicating the cause of the failure will be stored
	here.
	@return             If the entry point contains a descriptor set with the
	provided set_number, a pointer to that set is
	returned. The caller must not free this pointer.
	If no match can be found, or if an unrelated error
	occurs, the return value will be NULL. Detailed
	error results are written to *pResult.
	
	*/
	GetEntryPointDescriptorSet :: proc(p_module: ^ShaderModule, entry_point: cstring, set_number: u32, p_result: ^Result) -> ^DescriptorSet ---

	/* @fn spvReflectGetInputVariableByLocation
	
	@param  p_module  Pointer to an instance of SpvReflectShaderModule.
	@param  location  The "location" value of the requested input variable.
	A location of 0xFFFFFFFF will always return NULL
	with *p_result == ELEMENT_NOT_FOUND.
	@param  p_result  If successful, SPV_REFLECT_RESULT_SUCCESS will be
	written to *p_result. Otherwise, a error code
	indicating the cause of the failure will be stored
	here.
	@return           If the module contains an input interface variable
	with the provided location value, a pointer to that
	variable is returned. The caller must not free this
	pointer.
	If no match can be found, or if an unrelated error
	occurs, the return value will be NULL. Detailed
	error results are written to *pResult.
	@note
	
	*/
	GetInputVariableByLocation :: proc(p_module: ^ShaderModule, location: u32, p_result: ^Result) -> ^InterfaceVariable ---
	GetInputVariable           :: proc(p_module: ^ShaderModule, location: u32, p_result: ^Result) -> ^InterfaceVariable ---

	/* @fn spvReflectGetEntryPointInputVariableByLocation
	
	@param  p_module    Pointer to an instance of SpvReflectShaderModule.
	@param  entry_point The entry point to get the input variable from.
	@param  location    The "location" value of the requested input variable.
	A location of 0xFFFFFFFF will always return NULL
	with *p_result == ELEMENT_NOT_FOUND.
	@param  p_result    If successful, SPV_REFLECT_RESULT_SUCCESS will be
	written to *p_result. Otherwise, a error code
	indicating the cause of the failure will be stored
	here.
	@return             If the entry point contains an input interface variable
	with the provided location value, a pointer to that
	variable is returned. The caller must not free this
	pointer.
	If no match can be found, or if an unrelated error
	occurs, the return value will be NULL. Detailed
	error results are written to *pResult.
	@note
	
	*/
	GetEntryPointInputVariableByLocation :: proc(p_module: ^ShaderModule, entry_point: cstring, location: u32, p_result: ^Result) -> ^InterfaceVariable ---

	/* @fn spvReflectGetInputVariableBySemantic
	
	@param  p_module  Pointer to an instance of SpvReflectShaderModule.
	@param  semantic  The "semantic" value of the requested input variable.
	A semantic of NULL will return NULL.
	A semantic of "" will always return NULL with
	*p_result == ELEMENT_NOT_FOUND.
	@param  p_result  If successful, SPV_REFLECT_RESULT_SUCCESS will be
	written to *p_result. Otherwise, a error code
	indicating the cause of the failure will be stored
	here.
	@return           If the module contains an input interface variable
	with the provided semantic, a pointer to that
	variable is returned. The caller must not free this
	pointer.
	If no match can be found, or if an unrelated error
	occurs, the return value will be NULL. Detailed
	error results are written to *pResult.
	@note
	
	*/
	GetInputVariableBySemantic :: proc(p_module: ^ShaderModule, semantic: cstring, p_result: ^Result) -> ^InterfaceVariable ---

	/* @fn spvReflectGetEntryPointInputVariableBySemantic
	
	@param  p_module  Pointer to an instance of SpvReflectShaderModule.
	@param  entry_point The entry point to get the input variable from.
	@param  semantic  The "semantic" value of the requested input variable.
	A semantic of NULL will return NULL.
	A semantic of "" will always return NULL with
	*p_result == ELEMENT_NOT_FOUND.
	@param  p_result  If successful, SPV_REFLECT_RESULT_SUCCESS will be
	written to *p_result. Otherwise, a error code
	indicating the cause of the failure will be stored
	here.
	@return           If the entry point contains an input interface variable
	with the provided semantic, a pointer to that
	variable is returned. The caller must not free this
	pointer.
	If no match can be found, or if an unrelated error
	occurs, the return value will be NULL. Detailed
	error results are written to *pResult.
	@note
	
	*/
	GetEntryPointInputVariableBySemantic :: proc(p_module: ^ShaderModule, entry_point: cstring, semantic: cstring, p_result: ^Result) -> ^InterfaceVariable ---

	/* @fn spvReflectGetOutputVariableByLocation
	
	@param  p_module  Pointer to an instance of SpvReflectShaderModule.
	@param  location  The "location" value of the requested output variable.
	A location of 0xFFFFFFFF will always return NULL
	with *p_result == ELEMENT_NOT_FOUND.
	@param  p_result  If successful, SPV_REFLECT_RESULT_SUCCESS will be
	written to *p_result. Otherwise, a error code
	indicating the cause of the failure will be stored
	here.
	@return           If the module contains an output interface variable
	with the provided location value, a pointer to that
	variable is returned. The caller must not free this
	pointer.
	If no match can be found, or if an unrelated error
	occurs, the return value will be NULL. Detailed
	error results are written to *pResult.
	@note
	
	*/
	GetOutputVariableByLocation :: proc(p_module: ^ShaderModule, location: u32, p_result: ^Result) -> ^InterfaceVariable ---
	GetOutputVariable           :: proc(p_module: ^ShaderModule, location: u32, p_result: ^Result) -> ^InterfaceVariable ---

	/* @fn spvReflectGetEntryPointOutputVariableByLocation
	
	@param  p_module     Pointer to an instance of SpvReflectShaderModule.
	@param  entry_point  The entry point to get the output variable from.
	@param  location     The "location" value of the requested output variable.
	A location of 0xFFFFFFFF will always return NULL
	with *p_result == ELEMENT_NOT_FOUND.
	@param  p_result     If successful, SPV_REFLECT_RESULT_SUCCESS will be
	written to *p_result. Otherwise, a error code
	indicating the cause of the failure will be stored
	here.
	@return              If the entry point contains an output interface variable
	with the provided location value, a pointer to that
	variable is returned. The caller must not free this
	pointer.
	If no match can be found, or if an unrelated error
	occurs, the return value will be NULL. Detailed
	error results are written to *pResult.
	@note
	
	*/
	GetEntryPointOutputVariableByLocation :: proc(p_module: ^ShaderModule, entry_point: cstring, location: u32, p_result: ^Result) -> ^InterfaceVariable ---

	/* @fn spvReflectGetOutputVariableBySemantic
	
	@param  p_module  Pointer to an instance of SpvReflectShaderModule.
	@param  semantic  The "semantic" value of the requested output variable.
	A semantic of NULL will return NULL.
	A semantic of "" will always return NULL with
	*p_result == ELEMENT_NOT_FOUND.
	@param  p_result  If successful, SPV_REFLECT_RESULT_SUCCESS will be
	written to *p_result. Otherwise, a error code
	indicating the cause of the failure will be stored
	here.
	@return           If the module contains an output interface variable
	with the provided semantic, a pointer to that
	variable is returned. The caller must not free this
	pointer.
	If no match can be found, or if an unrelated error
	occurs, the return value will be NULL. Detailed
	error results are written to *pResult.
	@note
	
	*/
	GetOutputVariableBySemantic :: proc(p_module: ^ShaderModule, semantic: cstring, p_result: ^Result) -> ^InterfaceVariable ---

	/* @fn spvReflectGetEntryPointOutputVariableBySemantic
	
	@param  p_module  Pointer to an instance of SpvReflectShaderModule.
	@param  entry_point  The entry point to get the output variable from.
	@param  semantic  The "semantic" value of the requested output variable.
	A semantic of NULL will return NULL.
	A semantic of "" will always return NULL with
	*p_result == ELEMENT_NOT_FOUND.
	@param  p_result  If successful, SPV_REFLECT_RESULT_SUCCESS will be
	written to *p_result. Otherwise, a error code
	indicating the cause of the failure will be stored
	here.
	@return           If the entry point contains an output interface variable
	with the provided semantic, a pointer to that
	variable is returned. The caller must not free this
	pointer.
	If no match can be found, or if an unrelated error
	occurs, the return value will be NULL. Detailed
	error results are written to *pResult.
	@note
	
	*/
	GetEntryPointOutputVariableBySemantic :: proc(p_module: ^ShaderModule, entry_point: cstring, semantic: cstring, p_result: ^Result) -> ^InterfaceVariable ---

	/*! @fn spvReflectGetPushConstantBlock
	
	@param  p_module  Pointer to an instance of SpvReflectShaderModule.
	@param  index     The index of the desired block within the module's
	array of push constant blocks.
	@param  p_result  If successful, SPV_REFLECT_RESULT_SUCCESS will be
	written to *p_result. Otherwise, a error code
	indicating the cause of the failure will be stored
	here.
	@return           If the provided index is within range, a pointer to
	the corresponding push constant block is returned.
	The caller must not free this pointer.
	If no match can be found, or if an unrelated error
	occurs, the return value will be NULL. Detailed
	error results are written to *pResult.
	
	*/
	GetPushConstantBlock :: proc(p_module: ^ShaderModule, index: u32, p_result: ^Result) -> ^BlockVariable ---
	GetPushConstant      :: proc(p_module: ^ShaderModule, index: u32, p_result: ^Result) -> ^BlockVariable ---

	/*! @fn spvReflectGetEntryPointPushConstantBlock
	@brief  Get the push constant block corresponding to the given entry point.
	As by the Vulkan specification there can be no more than one push
	constant block used by a given entry point, so if there is one it will
	be returned, otherwise NULL will be returned.
	@param  p_module     Pointer to an instance of SpvReflectShaderModule.
	@param  entry_point  The entry point to get the push constant block from.
	@param  p_result     If successful, SPV_REFLECT_RESULT_SUCCESS will be
	written to *p_result. Otherwise, a error code
	indicating the cause of the failure will be stored
	here.
	@return              If the provided index is within range, a pointer to
	the corresponding push constant block is returned.
	The caller must not free this pointer.
	If no match can be found, or if an unrelated error
	occurs, the return value will be NULL. Detailed
	error results are written to *pResult.
	
	*/
	GetEntryPointPushConstantBlock :: proc(p_module: ^ShaderModule, entry_point: cstring, p_result: ^Result) -> ^BlockVariable ---

	/*! @fn spvReflectChangeDescriptorBindingNumbers
	@brief  Assign new set and/or binding numbers to a descriptor binding.
	In addition to updating the reflection data, this function modifies
	the underlying SPIR-V bytecode. The updated code can be retrieved
	with spvReflectGetCode().  If the binding is used in multiple
	entry points within the module, it will be changed in all of them.
	@param  p_module            Pointer to an instance of SpvReflectShaderModule.
	@param  p_binding           Pointer to the descriptor binding to modify.
	@param  new_binding_number  The new binding number to assign to the
	provided descriptor binding.
	To leave the binding number unchanged, pass
	SPV_REFLECT_BINDING_NUMBER_DONT_CHANGE.
	@param  new_set_number      The new set number to assign to the
	provided descriptor binding. Successfully changing
	a descriptor binding's set number invalidates all
	existing SpvReflectDescriptorBinding and
	SpvReflectDescriptorSet pointers from this module.
	To leave the set number unchanged, pass
	SPV_REFLECT_SET_NUMBER_DONT_CHANGE.
	@return                     If successful, returns SPV_REFLECT_RESULT_SUCCESS.
	Otherwise, the error code indicates the cause of
	the failure.
	*/
	ChangeDescriptorBindingNumbers :: proc(p_module: ^ShaderModule, p_binding: ^DescriptorBinding, new_binding_number: u32, new_set_number: u32) -> Result ---
	ChangeDescriptorBindingNumber  :: proc(p_module: ^ShaderModule, p_descriptor_binding: ^DescriptorBinding, new_binding_number: u32, optional_new_set_number: u32) -> Result ---

	/*! @fn spvReflectChangeDescriptorSetNumber
	@brief  Assign a new set number to an entire descriptor set (including
	all descriptor bindings in that set).
	In addition to updating the reflection data, this function modifies
	the underlying SPIR-V bytecode. The updated code can be retrieved
	with spvReflectGetCode().  If the descriptor set is used in
	multiple entry points within the module, it will be modified in all
	of them.
	@param  p_module        Pointer to an instance of SpvReflectShaderModule.
	@param  p_set           Pointer to the descriptor binding to modify.
	@param  new_set_number  The new set number to assign to the
	provided descriptor set, and all its descriptor
	bindings. Successfully changing a descriptor
	binding's set number invalidates all existing
	SpvReflectDescriptorBinding and
	SpvReflectDescriptorSet pointers from this module.
	To leave the set number unchanged, pass
	SPV_REFLECT_SET_NUMBER_DONT_CHANGE.
	@return                 If successful, returns SPV_REFLECT_RESULT_SUCCESS.
	Otherwise, the error code indicates the cause of
	the failure.
	*/
	ChangeDescriptorSetNumber :: proc(p_module: ^ShaderModule, p_set: ^DescriptorSet, new_set_number: u32) -> Result ---

	/*! @fn spvReflectChangeInputVariableLocation
	@brief  Assign a new location to an input interface variable.
	In addition to updating the reflection data, this function modifies
	the underlying SPIR-V bytecode. The updated code can be retrieved
	with spvReflectGetCode().
	It is the caller's responsibility to avoid assigning the same
	location to multiple input variables.  If the input variable is used
	by multiple entry points in the module, it will be changed in all of
	them.
	@param  p_module          Pointer to an instance of SpvReflectShaderModule.
	@param  p_input_variable  Pointer to the input variable to update.
	@param  new_location      The new location to assign to p_input_variable.
	@return                   If successful, returns SPV_REFLECT_RESULT_SUCCESS.
	Otherwise, the error code indicates the cause of
	the failure.
	
	*/
	ChangeInputVariableLocation :: proc(p_module: ^ShaderModule, p_input_variable: ^InterfaceVariable, new_location: u32) -> Result ---

	/*! @fn spvReflectChangeOutputVariableLocation
	@brief  Assign a new location to an output interface variable.
	In addition to updating the reflection data, this function modifies
	the underlying SPIR-V bytecode. The updated code can be retrieved
	with spvReflectGetCode().
	It is the caller's responsibility to avoid assigning the same
	location to multiple output variables.  If the output variable is used
	by multiple entry points in the module, it will be changed in all of
	them.
	@param  p_module          Pointer to an instance of SpvReflectShaderModule.
	@param  p_output_variable Pointer to the output variable to update.
	@param  new_location      The new location to assign to p_output_variable.
	@return                   If successful, returns SPV_REFLECT_RESULT_SUCCESS.
	Otherwise, the error code indicates the cause of
	the failure.
	
	*/
	ChangeOutputVariableLocation :: proc(p_module: ^ShaderModule, p_output_variable: ^InterfaceVariable, new_location: u32) -> Result ---

	/*! @fn spvReflectSourceLanguage
	
	@param  source_lang  The source language code.
	@return Returns string of source language specified in \a source_lang.
	The caller must not free the memory associated with this string.
	*/
	SourceLanguage :: proc(source_lang: SpvSourceLanguage) -> cstring ---

	/*! @fn spvReflectBlockVariableTypeName
	
	@param  p_var Pointer to block variable.
	@return Returns string of block variable's type description type name
	or NULL if p_var is NULL.
	*/
	BlockVariableTypeName :: proc(p_var: ^BlockVariable) -> cstring ---
}

