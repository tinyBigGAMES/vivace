{==============================================================================
         _       ve'va'CHe
  __   _(_)_   ____ _  ___ ___ ™
  \ \ / / \ \ / / _` |/ __/ _ \
   \ V /| |\ V / (_| | (_|  __/
    \_/ |_| \_/ \__,_|\___\___|
                   Game Toolkit

  Copyright © 2020-21 tinyBigGAMES™ LLC
  All rights reserved.

  Website: https://tinybiggames.com
  Email  : support@tinybiggames.com

  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions are met:

  1. The origin of this software must not be misrepresented; you must not
     claim that you wrote the original software. If you use this software in
     a product, an acknowledgment in the product documentation would be
     appreciated but is not required.

  2. Redistributions of source code must retain the above copyright
     notice, this list of conditions and the following disclaimer.

  3. Redistributions in binary form must reproduce the above copyright
     notice, this list of conditions and the following disclaimer in
     the documentation and/or other materials provided with the
     distribution.

  4. Neither the name of the copyright holder nor the names of its
     contributors may be used to endorse or promote products derived
     from this software without specific prior written permission.

  5. All video, audio, graphics and other content accessed through the
     software in this distro is the property of the applicable content owner
     and may be protected by applicable copyright law. This License gives
     Customer no rights to such content, and Company disclaims any liability
     for misuse of content.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
  "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
  LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
  FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
  COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
  INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
  SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
  HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
  STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
  OF THE POSSIBILITY OF SUCH DAMAGE.
============================================================================== }

unit Vivace.Entity;

{$I Vivace.Defines.inc }

interface

uses
  System.SysUtils,
  Vivace.Base,
  Vivace.Common,
  Vivace.Math,
  Vivace.Sprite,
  Vivace.Color;

type

 { TEntity }
  TEntity = class(TBaseObject)
  protected
    FSprite      : TSprite;
    FGroup       : Integer;
    FFrame       : Integer;
    FFrameFPS    : Single;
    FFrameTimer  : Single;
    FPos         : TVector;
    FDir         : TVector;
    FScale       : Single;
    FAngle       : Single;
    FAngleOffset : Single;
    FColor       : TColor;
    FHFlip       : Boolean;
    FVFlip       : Boolean;
    FLoopFrame   : Boolean;
    FWidth       : Single;
    FHeight      : Single;
    FRadius      : Single;
    FFirstFrame  : Integer;
    FLastFrame   : Integer;
    FShrinkFactor: Single;
    FOrigin      : TVector;
    FRenderPolyPoint: Boolean;
  public
    constructor Create; override;
    destructor Destroy; override;

    procedure Init(aSprite: TSprite; aGroup: Integer);

    procedure SetFrameRange(aFirst: Integer; aLast: Integer);
    function  NextFrame: Boolean;
    function  PrevFrame: Boolean;
    function  GetFrame: Integer;
    procedure SetFrame(aFrame: Integer);
    function  GetFrameFPS: Single;
    procedure SetFrameFPS(aFrameFPS: Single);
    function  GetFirstFrame: Integer;
    function  GetLastFrame: Integer;

    procedure SetPosAbs(aX: Single; aY: Single);
    procedure SetPosRel(aX: Single; aY: Single);
    function  GetPos: TVector;
    function  GetDir: TVector;

    procedure SetScaleAbs(aScale: Single);
    procedure SetScaleRel(aScale: Single);
    function  GetAngle: Single;

    function  GetAngleOffset: Single;
    procedure SetAngleOffset(aAngle: Single);

    procedure RotateAbs(aAngle: Single);
    procedure RotateRel(aAngle: Single);
    function  RotateToAngle(aAngle: Single; aSpeed: Single): Boolean;
    function  RotateToPos(aX: Single; aY: Single; aSpeed: Single): Boolean;
    function  RotateToPosAt(aSrcX: Single; aSrcY: Single; aDestX: Single; aDestY: Single; aSpeed: Single): Boolean;

    procedure Thrust(aSpeed: Single);
    procedure ThrustAngle(aAngle: Single; aSpeed: Single);
    function  ThrustToPos(aThrustSpeed: Single; aRotSpeed: Single; aDestX: Single; aDestY: Single; aSlowdownDist: Single; aStopDist: Single; aStopSpeed: Single; aStopSpeedEpsilon: Single; aDeltaTime: Single): Boolean;

    function  IsVisible(aVirtualX: Single; aVirtualY: Single): Boolean;
    function  IsFullyVisible(aVirtualX: Single; aVirtualY: Single): Boolean;

    function  Overlap(aX: Single; aY: Single; aRadius: Single; aShrinkFactor: Single): Boolean; overload;
    function  Overlap(aEntity: TEntity): Boolean; overload;

    procedure Render(aVirtualX: Single; aVirtualY: Single);
    procedure RenderAt(aX: Single; aY: Single);

    function  GetSprite: TSprite;
    function  GetGroup: Integer;
    function  GetScale: Single;

    function  GetColor: TColor;
    procedure SetColor(aColor: TColor);

    procedure GetFlipMode(aHFlip: PBoolean; aVFlip: PBoolean);
    procedure SetFlipMode(aHFlip: PBoolean; aVFlip: PBoolean);

    function  GetLoopFrame: Boolean;
    procedure SetLoopFrame(aLoop: Boolean);

    function  GetWidth: Single;
    function  GetHeight: Single;
    function  GetRadius: Single;

    function  GetShrinkFactor: Single;
    procedure SetShrinkFactor(aShrinkFactor: Single);

    procedure SetRenderPolyPoint(aRenderPolyPoint: Boolean);
    function  GetRenderPolyPoint: Boolean;
    procedure TracePolyPoint(aMju: Single=6; aMaxStepBack: Integer=12; aAlphaThreshold: Integer=70; aOrigin: PVector=nil);
    function  CollidePolyPoint(aEntity: TEntity; var aHitPos: TVector): Boolean;
    function  CollidePolyPointPoint(var aPoint: TVector): Boolean;
  end;

implementation

uses
  Vivace.Utils,
  Vivace.Bitmap,
  Vivace.PolyPoint,
  Vivace.Collision,
  Vivace.Engine;

{ TEntity }
constructor TEntity.Create;
begin
  inherited;
end;

destructor TEntity.Destroy;
begin
  inherited;
end;

procedure  TEntity.Init(aSprite: TSprite; aGroup: Integer);
begin
  FSprite      := aSprite;
  FGroup       := aGroup;
  FFrame       := 0;
  FFrameFPS    := 15;
  FScale       := 1.0;
  FAngle       := 0;
  FAngleOffset := 0;
  FColor       := WHITE;
  FHFlip       := False;
  FVFlip       := False;
  FLoopFrame   := True;
  FRenderPolyPoint := False;
  FShrinkFactor:= 1.0;
  FOrigin.X := 0.5;
  FOrigin.Y := 0.5;
  FFrameTimer := 0;
  SetPosAbs(0, 0);
  SetFrameRange(0, aSprite.GetImageCount(FGroup)-1);
  SetFrame(FFrame);
end;

procedure TEntity.SetFrameRange(aFirst: Integer; aLast: Integer);
begin
  FFirstFrame := aFirst;
  FLastFrame  := aLast;
end;

function  TEntity.NextFrame: Boolean;
begin
  Result := False;
  if gEngine.FrameSpeed(FFrameTimer, FFrameFPS) then
  begin
    Inc(FFrame);
    if FFrame > FLastFrame then
    begin
      if FLoopFrame then
        FFrame := FFirstFrame
      else
        FFrame := FLastFrame;
      Result := True;
    end;
  end;
  SetFrame(FFrame);
end;

function  TEntity.PrevFrame: Boolean;
begin
  Result := False;
  if gEngine.FrameSpeed(FFrameTimer, FFrameFPS) then
  begin
    Dec(FFrame);
    if FFrame < FFirstFrame then
    begin
      if FLoopFrame then
        FFrame := FLastFrame
      else
        FFrame := FFirstFrame;
      Result := True;
    end;
  end;

  SetFrame(FFrame);
end;

procedure TEntity.SetPosAbs(aX: Single; aY: Single);
begin
  FPos.X := aX;
  FPos.Y := aY;
  FDir.X := 0;
  FDir.Y := 0;
end;

procedure TEntity.SetPosRel(aX: Single; aY: Single);
begin
  FPos.X := FPos.X + aX;
  FPos.Y := FPos.Y + aY;
  FDir.X := aX;
  FDir.Y := aY;
end;

procedure TEntity.SetScaleAbs(aScale: Single);
begin
  FScale := aScale;
  SetFrame(FFrame);
end;

procedure TEntity.SetScaleRel(aScale: Single);
begin
  FScale := FScale + aScale;
  SetFrame(FFrame);
end;

procedure TEntity.SetAngleOffset(aAngle: Single);
begin
  aAngle := aAngle + FAngleOffset;
  TMath.ClipValue(aAngle, 0, 360, True);
  FAngleOffset := aAngle;
end;

procedure TEntity.RotateAbs(aAngle: Single);
begin
  TMath.ClipValue(aAngle, 0, 360, True);
  FAngle := aAngle;
end;

procedure TEntity.RotateRel(aAngle: Single);
begin
  aAngle := aAngle + FAngle;
  TMath.ClipValue(aAngle, 0, 360, True);
  FAngle := aAngle;
end;

function  TEntity.RotateToAngle(aAngle: Single; aSpeed: Single): Boolean;
var
  Step: Single;
  Len : Single;
  S   : Single;
begin
  Result := False;
  Step := TMath.AngleDifference(FAngle, aAngle);
  Len  := Sqrt(Step*Step);
  if Len = 0 then
    Exit;
  S    := (Step / Len) * aSpeed;
  FAngle := FAngle + S;
  if TMath.SameValue(Step, 0, S) then
  begin
    RotateAbs(aAngle);
    Result := True;
  end;
end;

function  TEntity.RotateToPos(aX: Single; aY: Single; aSpeed: Single): Boolean;
var
  Angle: Single;
  Step : Single;
  Len  : Single;
  S    : Single;
  tmpPos  : TVector;
begin
  Result := False;
  tmpPos.X  := aX;
  tmpPos.Y  := aY;

  Angle := -FPos.Angle(tmpPos);
  Step := TMath.AngleDifference(FAngle, Angle);
  Len  := Sqrt(Step*Step);
  if Len = 0 then
    Exit;
  S := (Step / Len) * aSpeed;

  if not TMath.SameValue(Step, S, aSpeed) then
    RotateRel(S)
  else begin
    RotateRel(Step);
    Result := True;
  end;
end;

function  TEntity.RotateToPosAt(aSrcX: Single; aSrcY: Single; aDestX: Single; aDestY: Single; aSpeed: Single): Boolean;
var
  Angle: Single;
  Step : Single;
  Len  : Single;
  S    : Single;
  SPos,DPos : TVector;
begin
  Result := False;
  SPos.X := aSrcX;
  SPos.Y := aSrcY;
  DPos.X  := aDestX;
  DPos.Y  := aDestY;

  Angle := SPos.Angle(DPos);
  Step := TMath.AngleDifference(FAngle, Angle);
  Len  := Sqrt(Step*Step);
  if Len = 0 then
    Exit;
  S := (Step / Len) * aSpeed;
  if not TMath.SameValue(Step, S, aSpeed) then
    RotateRel(S)
  else begin
    RotateRel(Step);
    Result := True;
  end;
end;

procedure TEntity.Thrust(aSpeed: Single);
var
  A, S: Single;
begin
  A := FAngle + 90.0;
  TMath.ClipValue(A, 0, 360, True);

  S := -aSpeed;

  FDir.x := TMath.AngleCos(Round(A)) * S;
  FDir.y := TMath.AngleSin(Round(A)) * S;

  FPos.x := FPos.x + FDir.x;
  FPos.y := FPos.y + FDir.y;
end;

procedure TEntity.ThrustAngle(aAngle: Single; aSpeed: Single);
var
  A, S: Single;
begin
  A := aAngle;

  TMath.ClipValue(A, 0, 360, True);

  S := -aSpeed;

  FDir.x := TMath.AngleCos(Round(A)) * S;
  FDir.y := TMath.AngleSin(Round(A)) * S;

  FPos.x := FPos.x + FDir.x;
  FPos.y := FPos.y + FDir.y;
end;

function  TEntity.ThrustToPos(aThrustSpeed: Single; aRotSpeed: Single; aDestX: Single; aDestY: Single; aSlowdownDist: Single; aStopDist: Single; aStopSpeed: Single; aStopSpeedEpsilon: Single; aDeltaTime: Single): Boolean;
var
  Dist : Single;
  Step : Single;
  Speed: Single;
  DestPos: TVector;
begin
  Result := False;

  if aSlowdownDist <= 0 then Exit;
  if aStopDist < 0 then aStopDist := 0;

  DestPos.X := aDestX;
  DestPos.Y := aDestY;
  Dist := FPos.Distance(DestPos);

  Dist := Dist - aStopDist;

  if  Dist > aSlowdownDist then
    begin
      Speed := aThrustSpeed;
    end
  else
    begin
      Step := (Dist/aSlowdownDist);
      Speed := (aThrustSpeed * Step);
      if Speed <= aStopSpeed then
      begin
        Speed := 0;
        Result := True;
      end;
    end;

  if RotateToPos(aDestX, aDestY, aRotSpeed*aDeltaTime) then
  begin
    Thrust(Speed*aDeltaTime);
  end;

end;

function  TEntity.IsVisible(aVirtualX: Single; aVirtualY: Single): Boolean;
var
  HW,HH: Single;
  vpx,vpy,vpw,vph: Integer;
  X,Y: Single;
begin
  Result := False;

  HW := FWidth / 2;
  HH := FHeight / 2;

  gEngine.Display.GetViewportSize(@vpx, @vpy, @vpw, @vph);

  Dec(vpW); Dec(vpH);

  X := FPos.X - aVirtualX;
  Y := FPos.Y - aVirtualY;

  if X > (vpW + HW) then Exit;
  if X < -HW    then Exit;
  if Y > (vpH + HH) then Exit;
  if Y < -HH    then Exit;

  Result := True;
end;

function  TEntity.IsFullyVisible(aVirtualX: Single; aVirtualY: Single): Boolean;
var
  HW,HH: Single;
  vpx,vpy,vpw,vph: Integer;
  X,Y: Single;
begin
  Result := False;

  HW := FWidth / 2;
  HH := FHeight / 2;

  gEngine.Display.GetViewportSize(@vpx, @vpy, @vpw, @vph);

  Dec(vpW); Dec(vpH);

  X := FPos.X - aVirtualX;
  Y := FPos.Y - aVirtualY;

  if X > (vpW - HW) then Exit;
  if X <  HW       then Exit;
  if Y > (vpH - HH) then Exit;
  if Y <  HH       then Exit;

  Result := True;
end;

function  TEntity.Overlap(aX: Single; aY: Single; aRadius: Single; aShrinkFactor: Single): Boolean;
var
  Dist: Single;
  R1  : Single;
  R2  : Single;
  V0,V1: TVector;
begin
  R1  := FRadius * aShrinkFactor;
  R2  := aRadius * aShrinkFactor;

  V0.X := FPos.X;
  V0.Y := FPos.Y;

  V1.x := aX;
  V1.y := aY;

  Dist := V0.Distance(V1);

  if (Dist < R1) or (Dist < R2) then
    Result := True
  else
   Result := False;
end;

function  TEntity.Overlap(aEntity: TEntity): Boolean;
begin
  Result := Overlap(aEntity.GetPos.X, aEntity.GetPos.Y, aEntity.GetRadius, aEntity.GetShrinkFactor);
end;

procedure TEntity.Render(aVirtualX: Single; aVirtualY: Single);
var
  X,Y: Single;
  SV: TVector;
begin
  X := FPos.X - aVirtualX;
  Y := FPos.Y - aVirtualY;
  SV.Assign(FScale, FScale);
  FSprite.DrawImage(FFrame, FGroup, X, Y, @FOrigin, @SV, FAngle, FColor, FHFlip, FVFlip, FRenderPolyPoint);
end;

procedure TEntity.RenderAt(aX: Single; aY: Single);
var
  SV: TVector;
begin
  SV.Assign(FScale, FScale);
  FSprite.DrawImage(FFrame, FGroup, aX, aY, @FOrigin, @SV, FAngle, FColor, FHFlip, FVFlip, FRenderPolyPoint);
end;

function  TEntity.GetSprite: TSprite;
begin
  Result := FSprite;
end;

function  TEntity.GetGroup: Integer;
begin
  Result := FGroup;
end;

function  TEntity.GetFrame: Integer;
begin
  Result := FFrame;
end;

procedure TEntity.SetFrame(aFrame: Integer);
var
  W,H: Single;
  R  : Single;
begin
  if aFrame > FSprite.GetImageCount(FGroup)-1  then
    FFrame := FSprite.GetImageCount(FGroup)-1
  else
    FFrame := aFrame;

  W := FSprite.GetImageWidth(FFrame, FGroup);
  H := FSprite.GetImageHeight(FFrame, FGroup);

  R := (W + H) / 2;

  FWidth  := W * FScale;
  FHeight := H * FScale;
  FRadius := R * FScale;
end;

function  TEntity.GetFrameFPS: Single;
begin
  Result := FFrameFPS;
end;

procedure TEntity.SetFrameFPS(aFrameFPS: Single);
begin
  FFrameFPS := aFrameFPS;
  FFrameTimer := 0;
end;

function  TEntity.GetFirstFrame: Integer;
begin
  Result := FFirstFrame;
end;

function  TEntity.GetLastFrame: Integer;
begin
  Result := FLastFrame;
end;

function  TEntity.GetPos: TVector;
begin
  Result := FPos;
end;

function  TEntity.GetDir: TVector;
begin
  Result := FDir;
end;

function  TEntity.GetScale: Single;
begin
  Result := FScale;
end;

function  TEntity.GetAngle: Single;
begin
  Result := FAngle;
end;

function  TEntity.GetAngleOffset: Single;
begin
  Result := FAngleOffset;
end;

function  TEntity.GetColor: TColor;
begin
 Result := FColor;
end;

procedure TEntity.SetColor(aColor: TColor);
begin
  FColor := aColor;
end;

procedure TEntity.GetFlipMode(aHFlip: PBoolean; aVFlip: PBoolean);
begin
  if Assigned(aHFlip) then
    aHFlip^ := FHFlip;
  if Assigned(aVFlip) then
    aVFlip^ := FVFlip;
end;

procedure TEntity.SetFlipMode(aHFlip: PBoolean; aVFlip: PBoolean);
begin
  if aHFlip <> nil then
    FHFlip := aHFlip^;

  if aVFlip <> nil then
    FVFlip := aVFlip^;
end;

function  TEntity.GetLoopFrame: Boolean;
begin
  Result := FLoopFrame;
end;

procedure TEntity.SetLoopFrame(aLoop: Boolean);
begin
  FLoopFrame := aLoop;
end;

function  TEntity.GetWidth: Single;
begin
  Result := FWidth;
end;

function  TEntity.GetHeight: Single;
begin
  Result := FHeight;
end;

function  TEntity.GetRadius: Single;
begin
  Result := FRadius;
end;

function  TEntity.GetShrinkFactor: Single;
begin
  Result := FShrinkFactor;
end;

procedure TEntity.SetShrinkFactor(aShrinkFactor: Single);
begin
  FShrinkFactor := aShrinkFactor;
end;

procedure TEntity.SetRenderPolyPoint(aRenderPolyPoint: Boolean);
begin
  FRenderPolyPoint := aRenderPolyPoint;
end;

function  TEntity.GetRenderPolyPoint: Boolean;
begin
  Result := FRenderPolyPoint;
end;

procedure TEntity.TracePolyPoint(aMju: Single=6; aMaxStepBack: Integer=12; aAlphaThreshold: Integer=70; aOrigin: PVector=nil);
begin
  FSprite.GroupPolyPointTrace(FGroup, aMju, aMaxStepBack, aAlphaThreshold, aOrigin);
end;

function  TEntity.CollidePolyPoint(aEntity: TEntity; var aHitPos: TVector): Boolean;
var
  ShrinkFactor: Single;
  HFlip,VFlip: Boolean;
begin
  ShrinkFactor := (FShrinkFactor + aEntity.GetShrinkFactor) / 2.0;

  aEntity.GetFlipMode(@HFlip, @VFlip);

  Result := FSprite.GroupPolyPointCollide(
    FFrame, FGroup, Round(FPos.X), Round(FPos.Y), FScale, FAngle, @FOrigin,
    FHFlip, FVFlip, aEntity.FSprite, aEntity.FFrame, aEntity.FGroup,
    Round(aEntity.FPos.X), Round(aEntity.FPos.Y), aEntity.FScale,
    aEntity.FAngle, @aEntity.FOrigin, HFlip, VFlip,
    ShrinkFactor, aHitPos);
end;

function  TEntity.CollidePolyPointPoint(var aPoint: TVector): Boolean;
var
  ShrinkFactor: Single;
begin
  ShrinkFactor := FShrinkFactor;

  Result := FSprite.GroupPolyPointCollidePoint(FFrame, FGroup, FPos.X, FPos.Y,
    FScale, FAngle, @FOrigin, FHFlip, FVFlip, ShrinkFactor, aPoint);
end;

end.
