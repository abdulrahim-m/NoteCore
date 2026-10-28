// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'task.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ScheduleDto {

 int get hour;
/// Create a copy of ScheduleDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ScheduleDtoCopyWith<ScheduleDto> get copyWith => _$ScheduleDtoCopyWithImpl<ScheduleDto>(this as ScheduleDto, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ScheduleDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ScheduleDto&&(identical(other.hour, _this.hour) || other.hour == _this.hour));
}


@override
int get hashCode {
  final _this = this as ScheduleDto;
  return Object.hash(runtimeType,_this.hour);
}

@override
String toString() {
  final _this = this as ScheduleDto;
  return 'ScheduleDto(hour: ${_this.hour})';
}


}

/// @nodoc
abstract mixin class $ScheduleDtoCopyWith<$Res>  {
  factory $ScheduleDtoCopyWith(ScheduleDto value, $Res Function(ScheduleDto) _then) = _$ScheduleDtoCopyWithImpl;
@useResult
$Res call({
 int hour
});




}
/// @nodoc
class _$ScheduleDtoCopyWithImpl<$Res>
    implements $ScheduleDtoCopyWith<$Res> {
  _$ScheduleDtoCopyWithImpl(this._self, this._then);

  final ScheduleDto _self;
  final $Res Function(ScheduleDto) _then;

/// Create a copy of ScheduleDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? hour = null,}) {
  return _then(_self.copyWith(
hour: null == hour ? _self.hour : hour // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ScheduleDto].
extension ScheduleDtoPatterns on ScheduleDto {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( ScheduleDto_Daily value)?  daily,TResult Function( ScheduleDto_EveryNDays value)?  everyNDays,TResult Function( ScheduleDto_Weekly value)?  weekly,TResult Function( ScheduleDto_Monthly value)?  monthly,TResult Function( ScheduleDto_Yearly value)?  yearly,required TResult orElse(),}){
final _that = this;
switch (_that) {
case ScheduleDto_Daily() when daily != null:
return daily(_that);case ScheduleDto_EveryNDays() when everyNDays != null:
return everyNDays(_that);case ScheduleDto_Weekly() when weekly != null:
return weekly(_that);case ScheduleDto_Monthly() when monthly != null:
return monthly(_that);case ScheduleDto_Yearly() when yearly != null:
return yearly(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( ScheduleDto_Daily value)  daily,required TResult Function( ScheduleDto_EveryNDays value)  everyNDays,required TResult Function( ScheduleDto_Weekly value)  weekly,required TResult Function( ScheduleDto_Monthly value)  monthly,required TResult Function( ScheduleDto_Yearly value)  yearly,}){
final _that = this;
switch (_that) {
case ScheduleDto_Daily():
return daily(_that);case ScheduleDto_EveryNDays():
return everyNDays(_that);case ScheduleDto_Weekly():
return weekly(_that);case ScheduleDto_Monthly():
return monthly(_that);case ScheduleDto_Yearly():
return yearly(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( ScheduleDto_Daily value)?  daily,TResult? Function( ScheduleDto_EveryNDays value)?  everyNDays,TResult? Function( ScheduleDto_Weekly value)?  weekly,TResult? Function( ScheduleDto_Monthly value)?  monthly,TResult? Function( ScheduleDto_Yearly value)?  yearly,}){
final _that = this;
switch (_that) {
case ScheduleDto_Daily() when daily != null:
return daily(_that);case ScheduleDto_EveryNDays() when everyNDays != null:
return everyNDays(_that);case ScheduleDto_Weekly() when weekly != null:
return weekly(_that);case ScheduleDto_Monthly() when monthly != null:
return monthly(_that);case ScheduleDto_Yearly() when yearly != null:
return yearly(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( int hour)?  daily,TResult Function( int days,  int hour)?  everyNDays,TResult Function( int dayOfWeek,  int hour)?  weekly,TResult Function( int dayOfMonth,  int hour)?  monthly,TResult Function( int month,  int dayOfMonth,  int hour)?  yearly,required TResult orElse(),}) {final _that = this;
switch (_that) {
case ScheduleDto_Daily() when daily != null:
return daily(_that.hour);case ScheduleDto_EveryNDays() when everyNDays != null:
return everyNDays(_that.days,_that.hour);case ScheduleDto_Weekly() when weekly != null:
return weekly(_that.dayOfWeek,_that.hour);case ScheduleDto_Monthly() when monthly != null:
return monthly(_that.dayOfMonth,_that.hour);case ScheduleDto_Yearly() when yearly != null:
return yearly(_that.month,_that.dayOfMonth,_that.hour);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( int hour)  daily,required TResult Function( int days,  int hour)  everyNDays,required TResult Function( int dayOfWeek,  int hour)  weekly,required TResult Function( int dayOfMonth,  int hour)  monthly,required TResult Function( int month,  int dayOfMonth,  int hour)  yearly,}) {final _that = this;
switch (_that) {
case ScheduleDto_Daily():
return daily(_that.hour);case ScheduleDto_EveryNDays():
return everyNDays(_that.days,_that.hour);case ScheduleDto_Weekly():
return weekly(_that.dayOfWeek,_that.hour);case ScheduleDto_Monthly():
return monthly(_that.dayOfMonth,_that.hour);case ScheduleDto_Yearly():
return yearly(_that.month,_that.dayOfMonth,_that.hour);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( int hour)?  daily,TResult? Function( int days,  int hour)?  everyNDays,TResult? Function( int dayOfWeek,  int hour)?  weekly,TResult? Function( int dayOfMonth,  int hour)?  monthly,TResult? Function( int month,  int dayOfMonth,  int hour)?  yearly,}) {final _that = this;
switch (_that) {
case ScheduleDto_Daily() when daily != null:
return daily(_that.hour);case ScheduleDto_EveryNDays() when everyNDays != null:
return everyNDays(_that.days,_that.hour);case ScheduleDto_Weekly() when weekly != null:
return weekly(_that.dayOfWeek,_that.hour);case ScheduleDto_Monthly() when monthly != null:
return monthly(_that.dayOfMonth,_that.hour);case ScheduleDto_Yearly() when yearly != null:
return yearly(_that.month,_that.dayOfMonth,_that.hour);case _:
  return null;

}
}

}

/// @nodoc


class ScheduleDto_Daily extends ScheduleDto {
  const ScheduleDto_Daily({required this.hour}): super._();
  

@override final  int hour;

/// Create a copy of ScheduleDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ScheduleDto_DailyCopyWith<ScheduleDto_Daily> get copyWith => _$ScheduleDto_DailyCopyWithImpl<ScheduleDto_Daily>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ScheduleDto_Daily&&(identical(other.hour, hour) || other.hour == hour));
}


@override
int get hashCode {
    return Object.hash(runtimeType,hour);
}

@override
String toString() {
    return 'ScheduleDto.daily(hour: $hour)';
}


}

/// @nodoc
abstract mixin class $ScheduleDto_DailyCopyWith<$Res> implements $ScheduleDtoCopyWith<$Res> {
  factory $ScheduleDto_DailyCopyWith(ScheduleDto_Daily value, $Res Function(ScheduleDto_Daily) _then) = _$ScheduleDto_DailyCopyWithImpl;
@override @useResult
$Res call({
 int hour
});




}
/// @nodoc
class _$ScheduleDto_DailyCopyWithImpl<$Res>
    implements $ScheduleDto_DailyCopyWith<$Res> {
  _$ScheduleDto_DailyCopyWithImpl(this._self, this._then);

  final ScheduleDto_Daily _self;
  final $Res Function(ScheduleDto_Daily) _then;

/// Create a copy of ScheduleDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? hour = null,}) {
  return _then(ScheduleDto_Daily(
hour: null == hour ? _self.hour : hour // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc


class ScheduleDto_EveryNDays extends ScheduleDto {
  const ScheduleDto_EveryNDays({required this.days, required this.hour}): super._();
  

 final  int days;
@override final  int hour;

/// Create a copy of ScheduleDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ScheduleDto_EveryNDaysCopyWith<ScheduleDto_EveryNDays> get copyWith => _$ScheduleDto_EveryNDaysCopyWithImpl<ScheduleDto_EveryNDays>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ScheduleDto_EveryNDays&&(identical(other.days, days) || other.days == days)&&(identical(other.hour, hour) || other.hour == hour));
}


@override
int get hashCode {
    return Object.hash(runtimeType,days,hour);
}

@override
String toString() {
    return 'ScheduleDto.everyNDays(days: $days, hour: $hour)';
}


}

/// @nodoc
abstract mixin class $ScheduleDto_EveryNDaysCopyWith<$Res> implements $ScheduleDtoCopyWith<$Res> {
  factory $ScheduleDto_EveryNDaysCopyWith(ScheduleDto_EveryNDays value, $Res Function(ScheduleDto_EveryNDays) _then) = _$ScheduleDto_EveryNDaysCopyWithImpl;
@override @useResult
$Res call({
 int days, int hour
});




}
/// @nodoc
class _$ScheduleDto_EveryNDaysCopyWithImpl<$Res>
    implements $ScheduleDto_EveryNDaysCopyWith<$Res> {
  _$ScheduleDto_EveryNDaysCopyWithImpl(this._self, this._then);

  final ScheduleDto_EveryNDays _self;
  final $Res Function(ScheduleDto_EveryNDays) _then;

/// Create a copy of ScheduleDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? days = null,Object? hour = null,}) {
  return _then(ScheduleDto_EveryNDays(
days: null == days ? _self.days : days // ignore: cast_nullable_to_non_nullable
as int,hour: null == hour ? _self.hour : hour // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc


class ScheduleDto_Weekly extends ScheduleDto {
  const ScheduleDto_Weekly({required this.dayOfWeek, required this.hour}): super._();
  

 final  int dayOfWeek;
@override final  int hour;

/// Create a copy of ScheduleDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ScheduleDto_WeeklyCopyWith<ScheduleDto_Weekly> get copyWith => _$ScheduleDto_WeeklyCopyWithImpl<ScheduleDto_Weekly>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ScheduleDto_Weekly&&(identical(other.dayOfWeek, dayOfWeek) || other.dayOfWeek == dayOfWeek)&&(identical(other.hour, hour) || other.hour == hour));
}


@override
int get hashCode {
    return Object.hash(runtimeType,dayOfWeek,hour);
}

@override
String toString() {
    return 'ScheduleDto.weekly(dayOfWeek: $dayOfWeek, hour: $hour)';
}


}

/// @nodoc
abstract mixin class $ScheduleDto_WeeklyCopyWith<$Res> implements $ScheduleDtoCopyWith<$Res> {
  factory $ScheduleDto_WeeklyCopyWith(ScheduleDto_Weekly value, $Res Function(ScheduleDto_Weekly) _then) = _$ScheduleDto_WeeklyCopyWithImpl;
@override @useResult
$Res call({
 int dayOfWeek, int hour
});




}
/// @nodoc
class _$ScheduleDto_WeeklyCopyWithImpl<$Res>
    implements $ScheduleDto_WeeklyCopyWith<$Res> {
  _$ScheduleDto_WeeklyCopyWithImpl(this._self, this._then);

  final ScheduleDto_Weekly _self;
  final $Res Function(ScheduleDto_Weekly) _then;

/// Create a copy of ScheduleDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? dayOfWeek = null,Object? hour = null,}) {
  return _then(ScheduleDto_Weekly(
dayOfWeek: null == dayOfWeek ? _self.dayOfWeek : dayOfWeek // ignore: cast_nullable_to_non_nullable
as int,hour: null == hour ? _self.hour : hour // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc


class ScheduleDto_Monthly extends ScheduleDto {
  const ScheduleDto_Monthly({required this.dayOfMonth, required this.hour}): super._();
  

 final  int dayOfMonth;
@override final  int hour;

/// Create a copy of ScheduleDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ScheduleDto_MonthlyCopyWith<ScheduleDto_Monthly> get copyWith => _$ScheduleDto_MonthlyCopyWithImpl<ScheduleDto_Monthly>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ScheduleDto_Monthly&&(identical(other.dayOfMonth, dayOfMonth) || other.dayOfMonth == dayOfMonth)&&(identical(other.hour, hour) || other.hour == hour));
}


@override
int get hashCode {
    return Object.hash(runtimeType,dayOfMonth,hour);
}

@override
String toString() {
    return 'ScheduleDto.monthly(dayOfMonth: $dayOfMonth, hour: $hour)';
}


}

/// @nodoc
abstract mixin class $ScheduleDto_MonthlyCopyWith<$Res> implements $ScheduleDtoCopyWith<$Res> {
  factory $ScheduleDto_MonthlyCopyWith(ScheduleDto_Monthly value, $Res Function(ScheduleDto_Monthly) _then) = _$ScheduleDto_MonthlyCopyWithImpl;
@override @useResult
$Res call({
 int dayOfMonth, int hour
});




}
/// @nodoc
class _$ScheduleDto_MonthlyCopyWithImpl<$Res>
    implements $ScheduleDto_MonthlyCopyWith<$Res> {
  _$ScheduleDto_MonthlyCopyWithImpl(this._self, this._then);

  final ScheduleDto_Monthly _self;
  final $Res Function(ScheduleDto_Monthly) _then;

/// Create a copy of ScheduleDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? dayOfMonth = null,Object? hour = null,}) {
  return _then(ScheduleDto_Monthly(
dayOfMonth: null == dayOfMonth ? _self.dayOfMonth : dayOfMonth // ignore: cast_nullable_to_non_nullable
as int,hour: null == hour ? _self.hour : hour // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc


class ScheduleDto_Yearly extends ScheduleDto {
  const ScheduleDto_Yearly({required this.month, required this.dayOfMonth, required this.hour}): super._();
  

 final  int month;
 final  int dayOfMonth;
@override final  int hour;

/// Create a copy of ScheduleDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ScheduleDto_YearlyCopyWith<ScheduleDto_Yearly> get copyWith => _$ScheduleDto_YearlyCopyWithImpl<ScheduleDto_Yearly>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ScheduleDto_Yearly&&(identical(other.month, month) || other.month == month)&&(identical(other.dayOfMonth, dayOfMonth) || other.dayOfMonth == dayOfMonth)&&(identical(other.hour, hour) || other.hour == hour));
}


@override
int get hashCode {
    return Object.hash(runtimeType,month,dayOfMonth,hour);
}

@override
String toString() {
    return 'ScheduleDto.yearly(month: $month, dayOfMonth: $dayOfMonth, hour: $hour)';
}


}

/// @nodoc
abstract mixin class $ScheduleDto_YearlyCopyWith<$Res> implements $ScheduleDtoCopyWith<$Res> {
  factory $ScheduleDto_YearlyCopyWith(ScheduleDto_Yearly value, $Res Function(ScheduleDto_Yearly) _then) = _$ScheduleDto_YearlyCopyWithImpl;
@override @useResult
$Res call({
 int month, int dayOfMonth, int hour
});




}
/// @nodoc
class _$ScheduleDto_YearlyCopyWithImpl<$Res>
    implements $ScheduleDto_YearlyCopyWith<$Res> {
  _$ScheduleDto_YearlyCopyWithImpl(this._self, this._then);

  final ScheduleDto_Yearly _self;
  final $Res Function(ScheduleDto_Yearly) _then;

/// Create a copy of ScheduleDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? month = null,Object? dayOfMonth = null,Object? hour = null,}) {
  return _then(ScheduleDto_Yearly(
month: null == month ? _self.month : month // ignore: cast_nullable_to_non_nullable
as int,dayOfMonth: null == dayOfMonth ? _self.dayOfMonth : dayOfMonth // ignore: cast_nullable_to_non_nullable
as int,hour: null == hour ? _self.hour : hour // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
