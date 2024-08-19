---
title: 基础01-Context
date: 2024-07-01 21:15:36
tags: Android-官方源码
categories: 
    - Android
    - 手撸Android源码
toc: true
language: zh-CN
---

## 大纲
- Context类
  - 注解
    - 用于标注文件、SharedPreferences、数据库的打开方式的注解
    - 用于标注bindService时，service的flags的注解
    - 用于标注registerReceiver时，receiver的flags的注解
    - 用于标注getService时，servicesName的注解
    - 用于标注createPackageContext、createPackageContextAsUser、createContextAsUser、createApplicationContext时的flags的注解
  - 常量定义
    - 对应上面注解中限制的常量
    - WAL

## Context类

Context是抽象类，具体实现在ContextImpl，Application，Service，Activity都直接或间接继承自ContextWrapper，ContextWrapper通过代理的方式调用真正的ContextImpl。

### 注解

```java
/** @hide */
@IntDef(flag = true, prefix = { "MODE_" }, value = {
        MODE_PRIVATE,
        MODE_WORLD_READABLE,
        MODE_WORLD_WRITEABLE,
        MODE_APPEND,
})
@Retention(RetentionPolicy.SOURCE)
public @interface FileMode {}

/** @hide */
@IntDef(flag = true, prefix = { "MODE_" }, value = {
        MODE_PRIVATE,
        MODE_WORLD_READABLE,
        MODE_WORLD_WRITEABLE,
        MODE_MULTI_PROCESS,
})
@Retention(RetentionPolicy.SOURCE)
public @interface PreferencesMode {}

/** @hide */
@IntDef(flag = true, prefix = { "MODE_" }, value = {
        MODE_PRIVATE,
        MODE_WORLD_READABLE,
        MODE_WORLD_WRITEABLE,
        MODE_ENABLE_WRITE_AHEAD_LOGGING,
        MODE_NO_LOCALIZED_COLLATORS,
})
@Retention(RetentionPolicy.SOURCE)
public @interface DatabaseMode {}
```

```java
/** @hide */
@IntDef(flag = true, prefix = { "BIND_" }, value = {
        BIND_AUTO_CREATE,
        BIND_DEBUG_UNBIND,
        BIND_NOT_FOREGROUND,
        BIND_ABOVE_CLIENT,
        BIND_ALLOW_OOM_MANAGEMENT,
        BIND_WAIVE_PRIORITY,
        BIND_IMPORTANT,
        BIND_ADJUST_WITH_ACTIVITY,
        BIND_NOT_PERCEPTIBLE,
        BIND_INCLUDE_CAPABILITIES
})
@Retention(RetentionPolicy.SOURCE)
public @interface BindServiceFlags {}
```

```java
/** @hide */
@IntDef(flag = true, prefix = { "RECEIVER_VISIBLE_" }, value = {
        RECEIVER_VISIBLE_TO_INSTANT_APPS
})
@Retention(RetentionPolicy.SOURCE)
public @interface RegisterReceiverFlags {}
```

```java
/** @hide */
@StringDef(suffix = { "_SERVICE" }, value = {
        POWER_SERVICE,
        //@hide: POWER_STATS_SERVICE,
        WINDOW_SERVICE,
        LAYOUT_INFLATER_SERVICE,
        ACCOUNT_SERVICE,
        ACTIVITY_SERVICE,
        ALARM_SERVICE,
        NOTIFICATION_SERVICE,
        ACCESSIBILITY_SERVICE,
        CAPTIONING_SERVICE,
        KEYGUARD_SERVICE,
        LOCATION_SERVICE,
        //@hide: COUNTRY_DETECTOR,
        SEARCH_SERVICE,
        SENSOR_SERVICE,
        SENSOR_PRIVACY_SERVICE,
        STORAGE_SERVICE,
        STORAGE_STATS_SERVICE,
        WALLPAPER_SERVICE,
        TIME_ZONE_RULES_MANAGER_SERVICE,
        VIBRATOR_MANAGER_SERVICE,
        VIBRATOR_SERVICE,
        //@hide: STATUS_BAR_SERVICE,
        CONNECTIVITY_SERVICE,
        PAC_PROXY_SERVICE,
        VCN_MANAGEMENT_SERVICE,
        //@hide: IP_MEMORY_STORE_SERVICE,
        IPSEC_SERVICE,
        VPN_MANAGEMENT_SERVICE,
        TEST_NETWORK_SERVICE,
        //@hide: UPDATE_LOCK_SERVICE,
        //@hide: NETWORKMANAGEMENT_SERVICE,
        NETWORK_STATS_SERVICE,
        //@hide: NETWORK_POLICY_SERVICE,
        WIFI_SERVICE,
        WIFI_AWARE_SERVICE,
        WIFI_P2P_SERVICE,
        WIFI_SCANNING_SERVICE,
        //@hide: LOWPAN_SERVICE,
        //@hide: WIFI_RTT_SERVICE,
        //@hide: ETHERNET_SERVICE,
        WIFI_RTT_RANGING_SERVICE,
        NSD_SERVICE,
        AUDIO_SERVICE,
        AUTH_SERVICE,
        FINGERPRINT_SERVICE,
        //@hide: FACE_SERVICE,
        BIOMETRIC_SERVICE,
        MEDIA_ROUTER_SERVICE,
        TELEPHONY_SERVICE,
        TELEPHONY_SUBSCRIPTION_SERVICE,
        CARRIER_CONFIG_SERVICE,
        EUICC_SERVICE,
        //@hide: MMS_SERVICE,
        TELECOM_SERVICE,
        CLIPBOARD_SERVICE,
        INPUT_METHOD_SERVICE,
        TEXT_SERVICES_MANAGER_SERVICE,
        TEXT_CLASSIFICATION_SERVICE,
        APPWIDGET_SERVICE,
        //@hide: VOICE_INTERACTION_MANAGER_SERVICE,
        //@hide: BACKUP_SERVICE,
        REBOOT_READINESS_SERVICE,
        ROLLBACK_SERVICE,
        DROPBOX_SERVICE,
        //@hide: DEVICE_IDLE_CONTROLLER,
        //@hide: POWER_WHITELIST_MANAGER,
        DEVICE_POLICY_SERVICE,
        UI_MODE_SERVICE,
        DOWNLOAD_SERVICE,
        NFC_SERVICE,
        BLUETOOTH_SERVICE,
        //@hide: SIP_SERVICE,
        USB_SERVICE,
        LAUNCHER_APPS_SERVICE,
        //@hide: SERIAL_SERVICE,
        //@hide: HDMI_CONTROL_SERVICE,
        INPUT_SERVICE,
        DISPLAY_SERVICE,
        //@hide COLOR_DISPLAY_SERVICE,
        USER_SERVICE,
        RESTRICTIONS_SERVICE,
        APP_OPS_SERVICE,
        ROLE_SERVICE,
        //@hide ROLE_CONTROLLER_SERVICE,
        CAMERA_SERVICE,
        //@hide: PLATFORM_COMPAT_SERVICE,
        //@hide: PLATFORM_COMPAT_NATIVE_SERVICE,
        PRINT_SERVICE,
        CONSUMER_IR_SERVICE,
        //@hide: TRUST_SERVICE,
        TV_INPUT_SERVICE,
        //@hide: TV_TUNER_RESOURCE_MGR_SERVICE,
        //@hide: NETWORK_SCORE_SERVICE,
        USAGE_STATS_SERVICE,
        MEDIA_SESSION_SERVICE,
        MEDIA_COMMUNICATION_SERVICE,
        BATTERY_SERVICE,
        JOB_SCHEDULER_SERVICE,
        //@hide: PERSISTENT_DATA_BLOCK_SERVICE,
        //@hide: OEM_LOCK_SERVICE,
        MEDIA_PROJECTION_SERVICE,
        MIDI_SERVICE,
        RADIO_SERVICE,
        HARDWARE_PROPERTIES_SERVICE,
        //@hide: SOUND_TRIGGER_SERVICE,
        SHORTCUT_SERVICE,
        //@hide: CONTEXTHUB_SERVICE,
        SYSTEM_HEALTH_SERVICE,
        //@hide: INCIDENT_SERVICE,
        //@hide: INCIDENT_COMPANION_SERVICE,
        //@hide: STATS_COMPANION_SERVICE,
        COMPANION_DEVICE_SERVICE,
        CROSS_PROFILE_APPS_SERVICE,
        //@hide: SYSTEM_UPDATE_SERVICE,
        //@hide: TIME_DETECTOR_SERVICE,
        //@hide: TIME_ZONE_DETECTOR_SERVICE,
        PERMISSION_SERVICE,
        LIGHTS_SERVICE,
        //@hide: PEOPLE_SERVICE,
        //@hide: DEVICE_STATE_SERVICE,
        //@hide: SPEECH_RECOGNITION_SERVICE,
        UWB_SERVICE,
        MEDIA_METRICS_SERVICE,
})
@Retention(RetentionPolicy.SOURCE)
public @interface ServiceName {}
```

```java
/** @hide */
@IntDef(flag = true, prefix = { "CONTEXT_" }, value = {
        CONTEXT_INCLUDE_CODE,
        CONTEXT_IGNORE_SECURITY,
        CONTEXT_RESTRICTED,
        CONTEXT_DEVICE_PROTECTED_STORAGE,
        CONTEXT_CREDENTIAL_PROTECTED_STORAGE,
        CONTEXT_REGISTER_PACKAGE,
})
@Retention(RetentionPolicy.SOURCE)
public @interface CreatePackageOptions {}
```

## 常量定义

文件创建、SP、数据库共享的的flags

```java
// 默认值，只能对当前app(相同user-id的进程)可见
public static final int MODE_PRIVATE = 0x0000;

// 允许其他app读，已弃用，强制使用会抛出SecurityException
@Deprecated
public static final int MODE_WORLD_READABLE = 0x0001;


// 允许其他app写，已弃用，强制使用会抛出SecurityException
@Deprecated
public static final int MODE_WORLD_WRITEABLE = 0x0002;
```

文件创建的flag
```java
// append，而不是覆盖
public static final int MODE_APPEND = 0x8000;
```

SP加载的flag
```java
// 不建议使用，没有进程同步的机制
// 为了一个app有多个进程时使用
// 跨进程数据管理方法可以用ContentProvider
@Deprecated
public static final int MODE_MULTI_PROCESS = 0x0004;
```

数据库的flag

```java
// write-ahead logging, WAL
/**
 * According To: https://www.w3cschool.cn/doc_postgresql_9_4/postgresql_9_4-wal-intro.html
 * Briefly, WAL's central concept is that changes to data files (where tables and indexes reside) 
 * must be written only after those changes have been logged, 
 * that is, after log records describing the changes have been flushed to permanent storage.
*/
// 在对数据进行写操作前，对写操作的log要先写入到持久化存储设备
// 启用WAL
public static final int MODE_ENABLE_WRITE_AHEAD_LOGGING = 0x0008;

// 启用本地化的操作
public static final int MODE_NO_LOCALIZED_COLLATORS = 0x0010;
```

- bindService的flags

```java
/**
 * <p>Note that prior to {@link android.os.Build.VERSION_CODES#ICE_CREAM_SANDWICH},
 * not supplying this flag would also impact how important the system
 * consider's the target service's process to be.  When set, the only way
 * for it to be raised was by binding from a service in which case it will
 * only be important when that activity is in the foreground.  Now to
 * achieve this behavior you must explicitly supply the new flag
 * {@link #BIND_ADJUST_WITH_ACTIVITY}.  For compatibility, old applications
 * that don't specify {@link #BIND_AUTO_CREATE} will automatically have
 * the flags {@link #BIND_WAIVE_PRIORITY} and
 * {@link #BIND_ADJUST_WITH_ACTIVITY} set for them in order to achieve
 * the same result.
 */
// 自动创建service
public static final int BIND_AUTO_CREATE = 0x0001;

// debug，打印调用栈
public static final int BIND_DEBUG_UNBIND = 0x0002;

// 不允许将service进程提升到前台，绑定时在前台而目标为后台时有效
public static final int BIND_NOT_FOREGROUND = 0x0004;

// Service的重要程度高于客户端，OOM时有限杀掉app而不是service
public static final int BIND_ABOVE_CLIENT = 0x0008;

/**
 * Flag for {@link #bindService}: allow the process hosting the bound
 * service to go through its normal memory management.  It will be
 * treated more like a running service, allowing the system to
 * (temporarily) expunge the process if low on memory or for some other
 * whim it may have, and being more aggressive about making it a candidate
 * to be killed (and restarted) if running for a long time.
 */
public static final int BIND_ALLOW_OOM_MANAGEMENT = 0x0010;

/**
 * Flag for {@link #bindService}: don't impact the scheduling or
 * memory management priority of the target service's hosting process.
 * Allows the service's process to be managed on the background LRU list
 * just like a regular application process in the background.
 */
public static final int BIND_WAIVE_PRIORITY = 0x0020;

/**
 * Flag for {@link #bindService}: this service is very important to
 * the client, so should be brought to the foreground process level
 * when the client is.  Normally a process can only be raised to the
 * visibility level by a client, even if that client is in the foreground.
 */
public static final int BIND_IMPORTANT = 0x0040;

/**
 * Flag for {@link #bindService}: If binding from an activity, allow the
 * target service's process importance to be raised based on whether the
 * activity is visible to the user, regardless whether another flag is
 * used to reduce the amount that the client process's overall importance
 * is used to impact it.
 */
public static final int BIND_ADJUST_WITH_ACTIVITY = 0x0080;

/**
 * Flag for {@link #bindService}: If binding from an app that is visible or user-perceptible,
 * lower the target service's importance to below the perceptible level. This allows
 * the system to (temporarily) expunge the bound process from memory to make room for more
 * important user-perceptible processes.
 */
public static final int BIND_NOT_PERCEPTIBLE = 0x00000100;

/**
 * Flag for {@link #bindService}: If binding from an app that has specific capabilities
 * due to its foreground state such as an activity or foreground service, then this flag will
 * allow the bound app to get the same capabilities, as long as it has the required permissions
 * as well.
 *
 * If binding from a top app and its target SDK version is at or above
 * {@link android.os.Build.VERSION_CODES#R}, the app needs to
 * explicitly use BIND_INCLUDE_CAPABILITIES flag to pass all capabilities to the service so the
 * other app can have while-use-use access such as location, camera, microphone from background.
 * If binding from a top app and its target SDK version is below
 * {@link android.os.Build.VERSION_CODES#R}, BIND_INCLUDE_CAPABILITIES is implicit.
 */
public static final int BIND_INCLUDE_CAPABILITIES = 0x000001000;

/***********    Public flags above this line ***********/
/***********    Hidden flags below this line ***********/

/**
 * Flag for {@link #bindService}: This flag is only intended to be used by the system to
 * indicate that a service binding is not considered as real package component usage and should
 * not generate a {@link android.app.usage.UsageEvents.Event#APP_COMPONENT_USED} event in usage
 * stats.
 * @hide
 */
public static final int BIND_NOT_APP_COMPONENT_USAGE = 0x00008000;

/**
 * Flag for {@link #bindService}: allow the process hosting the target service to be treated
 * as if it's as important as a perceptible app to the user and avoid the oom killer killing
 * this process in low memory situations until there aren't any other processes left but the
 * ones which are user-perceptible.
 *
 * @hide
 */
public static final int BIND_ALMOST_PERCEPTIBLE = 0x000010000;

/**
 * Flag for {@link #bindService}: allow the process hosting the target service to gain
 * {@link ActivityManager#PROCESS_CAPABILITY_NETWORK}, which allows it be able
 * to access network regardless of any power saving restrictions.
 *
 * @hide
 */
public static final int BIND_BYPASS_POWER_NETWORK_RESTRICTIONS = 0x00020000;

/**
 * Do not use. This flag is no longer needed nor used.
 * @hide
 */
@SystemApi
public static final int BIND_ALLOW_FOREGROUND_SERVICE_STARTS_FROM_BACKGROUND = 0x00040000;

/**
 * Flag for {@link #bindService}: This flag is intended to be used only by the system to adjust
 * the scheduling policy for IMEs (and any other out-of-process user-visible components that
 * work closely with the top app) so that UI hosted in such services can have the same
 * scheduling policy (e.g. SCHED_FIFO when it is enabled and TOP_APP_PRIORITY_BOOST otherwise)
 * as the actual top-app.
 * @hide
 */
public static final int BIND_SCHEDULE_LIKE_TOP_APP = 0x00080000;

/**
 * Flag for {@link #bindService}: allow background activity starts from the bound service's
 * process.
 * This flag is only respected if the caller is holding
 * {@link android.Manifest.permission#START_ACTIVITIES_FROM_BACKGROUND}.
 * @hide
 */
@SystemApi
public static final int BIND_ALLOW_BACKGROUND_ACTIVITY_STARTS = 0x00100000;

/**
 * @hide Flag for {@link #bindService}: the service being bound to represents a
 * protected system component, so must have association restrictions applied to it.
 * That is, a system config must have one or more allow-association tags limiting
 * which packages it can interact with.  If it does not have any such association
 * restrictions, a default empty set will be created.
 */
public static final int BIND_RESTRICT_ASSOCIATIONS = 0x00200000;

/**
 * @hide Flag for {@link #bindService}: allows binding to a service provided
 * by an instant app. Note that the caller may not have access to the instant
 * app providing the service which is a violation of the instant app sandbox.
 * This flag is intended ONLY for development/testing and should be used with
 * great care. Only the system is allowed to use this flag.
 */
public static final int BIND_ALLOW_INSTANT = 0x00400000;

/**
 * @hide Flag for {@link #bindService}: like {@link #BIND_NOT_FOREGROUND}, but puts it
 * up in to the important background state (instead of transient).
 */
public static final int BIND_IMPORTANT_BACKGROUND = 0x00800000;

/**
 * @hide Flag for {@link #bindService}: allows application hosting service to manage whitelists
 * such as temporary allowing a {@code PendingIntent} to bypass Power Save mode.
 */
public static final int BIND_ALLOW_WHITELIST_MANAGEMENT = 0x01000000;

/**
 * @hide Flag for {@link #bindService}: Like {@link #BIND_FOREGROUND_SERVICE},
 * but only applies while the device is awake.
 */
public static final int BIND_FOREGROUND_SERVICE_WHILE_AWAKE = 0x02000000;

/**
 * @hide Flag for {@link #bindService}: For only the case where the binding
 * is coming from the system, set the process state to FOREGROUND_SERVICE
 * instead of the normal maximum of IMPORTANT_FOREGROUND.  That is, this is
 * saying that the process shouldn't participate in the normal power reduction
 * modes (removing network access etc).
 */
public static final int BIND_FOREGROUND_SERVICE = 0x04000000;

/**
 * @hide Flag for {@link #bindService}: Treat the binding as hosting
 * an activity, an unbinding as the activity going in the background.
 * That is, when unbinding, the process when empty will go on the activity
 * LRU list instead of the regular one, keeping it around more aggressively
 * than it otherwise would be.  This is intended for use with IMEs to try
 * to keep IME processes around for faster keyboard switching.
 */
public static final int BIND_TREAT_LIKE_ACTIVITY = 0x08000000;

/**
 * @hide An idea that is not yet implemented.
 * Flag for {@link #bindService}: If binding from an activity, consider
 * this service to be visible like the binding activity is.  That is,
 * it will be treated as something more important to keep around than
 * invisible background activities.  This will impact the number of
 * recent activities the user can switch between without having them
 * restart.  There is no guarantee this will be respected, as the system
 * tries to balance such requests from one app vs. the importance of
 * keeping other apps around.
 */
public static final int BIND_VISIBLE = 0x10000000;

/**
 * @hide
 * Flag for {@link #bindService}: Consider this binding to be causing the target
 * process to be showing UI, so it will be do a UI_HIDDEN memory trim when it goes
 * away.
 */
public static final int BIND_SHOWING_UI = 0x20000000;

/**
 * Flag for {@link #bindService}: Don't consider the bound service to be
 * visible, even if the caller is visible.
 * @hide
 */
public static final int BIND_NOT_VISIBLE = 0x40000000;

/**
 * Flag for {@link #bindService}: The service being bound is an
 * {@link android.R.attr#isolatedProcess isolated},
 * {@link android.R.attr#externalService external} service.  This binds the service into the
 * calling application's package, rather than the package in which the service is declared.
 * <p>
 * When using this flag, the code for the service being bound will execute under the calling
 * application's package name and user ID.  Because the service must be an isolated process,
 * it will not have direct access to the application's data, though.
 *
 * The purpose of this flag is to allow applications to provide services that are attributed
 * to the app using the service, rather than the application providing the service.
 * </p>
 */
public static final int BIND_EXTERNAL_SERVICE = 0x80000000;

/**
 * These bind flags reduce the strength of the binding such that we shouldn't
 * consider it as pulling the process up to the level of the one that is bound to it.
 * @hide
 */
public static final int BIND_REDUCTION_FLAGS =
        Context.BIND_ALLOW_OOM_MANAGEMENT | Context.BIND_WAIVE_PRIORITY
                | Context.BIND_NOT_PERCEPTIBLE | Context.BIND_NOT_VISIBLE;
```

registerReceiver的flags

```java
/**
 * Flag for {@link #registerReceiver}: The receiver can receive broadcasts from Instant Apps.
 */
// 是否可以被Instant Apps接收到（google的小程序吧）
public static final int RECEIVER_VISIBLE_TO_INSTANT_APPS = 0x1;
```

getService的serviceName

```java

```

## 方法

### 部分get方法
```java
public abstract AssetManager getAssets();
public abstract Resources getResources();
public abstract PackageManager getPackageManager();
public abstract ContentResolver getContentResolver();
public abstract Looper getMainLooper();
public abstract Context getApplicationContext();

public Executor getMainExecutor() {
        // This is pretty inefficient, which is why ContextImpl overrides it
        return new HandlerExecutor(new Handler(getMainLooper()));
}
public abstract ClassLoader getClassLoader();
public abstract String getPackageName();
public abstract String getBasePackageName();
@NonNull
public String getOpPackageName() {
        throw new RuntimeException("Not implemented. Must override in a subclass.");
}
public abstract ApplicationInfo getApplicationInfo();
public abstract String getPackageResourcePath();
// 返回应用包的完整路径
public abstract String getPackageCodePath();

```

### systemService

```java
public abstract @Nullable String getSystemServiceName(@NonNull Class<?> serviceClass);
public abstract @Nullable Object getSystemService(@ServiceName @NonNull String name);
public final @Nullable <T> T getSystemService(@NonNull Class<T> serviceClass) { // 也可以通过Class对象获取
        String serviceName = getSystemServiceName(serviceClass);
        return serviceName != null ? (T)getSystemService(serviceName) : null;
}
```

### View相关
```java
// 返回进程中唯一的View ID
public int getNextAutofillId() {
        if (sLastAutofillId == View.LAST_APP_AUTOFILL_ID - 1) {
                sLastAutofillId = View.NO_ID;
        }
        sLastAutofillId++;
        return sLastAutofillId;
}
// 会有并发问题吗？？
```

### ComponentCallbacks
```java
public void registerComponentCallbacks(ComponentCallbacks callback) {
        getApplicationContext().registerComponentCallbacks(callback);
}
public void unregisterComponentCallbacks(ComponentCallbacks callback) {
        getApplicationContext().unregisterComponentCallbacks(callback);
}
// Callback包括:
// onConfigurationChanged
// onLowMemory: 调用时机没有明确定义，一般在内存不足，所有后台进程被kill之后，processes hosting service和前台用户界面被kill之前。
```

### 资源相关

```java
@NonNull
public final CharSequence getText(@StringRes int resId) {
        return getResources().getText(resId);
}

@NonNull
public final String getString(@StringRes int resId) {
        return getResources().getString(resId);
}

@NonNull
public final String getString(@StringRes int resId, Object... formatArgs) {
        return getResources().getString(resId, formatArgs);
}

@ColorInt
public final int getColor(@ColorRes int id) {
        return getResources().getColor(id, getTheme());
}

@Nullable
public final Drawable getDrawable(@DrawableRes int id) {
        return getResources().getDrawable(id, getTheme());
}

@NonNull
public final ColorStateList getColorStateList(@ColorRes int id) {
        return getResources().getColorStateList(id, getTheme());
}
```

### 主题相关

```java
public abstract void setTheme(@StyleRes int resid);

/** @hide Needed for some internal implementation...  not public because
 * you can't assume this actually means anything. */
@UnsupportedAppUsage
public int getThemeResId() {
        return 0;
}

@ViewDebug.ExportedProperty(deepExport = true)
public abstract Resources.Theme getTheme();

@NonNull
public final TypedArray obtainStyledAttributes(@NonNull @StyleableRes int[] attrs) {
        return getTheme().obtainStyledAttributes(attrs);
}

@NonNull
public final TypedArray obtainStyledAttributes(@StyleRes int resid,
        @NonNull @StyleableRes int[] attrs) throws Resources.NotFoundException {
        return getTheme().obtainStyledAttributes(resid, attrs);
}

@NonNull
public final TypedArray obtainStyledAttributes(
        @Nullable AttributeSet set, @NonNull @StyleableRes int[] attrs) {
        return getTheme().obtainStyledAttributes(set, attrs, 0, 0);
}

@NonNull
public final TypedArray obtainStyledAttributes(@Nullable AttributeSet set,
        @NonNull @StyleableRes int[] attrs, @AttrRes int defStyleAttr,
        @StyleRes int defStyleRes) {
        return getTheme().obtainStyledAttributes(
        set, attrs, defStyleAttr, defStyleRes);
}
```

### SP

```java
public abstract SharedPreferences getSharedPreferences(String name, @PreferencesMode int mode);
@SuppressWarnings("HiddenAbstractMethod")
public abstract SharedPreferences getSharedPreferences(File file, @PreferencesMode int mode);
public abstract boolean moveSharedPreferencesFrom(Context sourceContext, String name); // 将一个context中的sp移动到当前context中
public abstract boolean deleteSharedPreferences(String name);
```

### 文件

```java
// 打开私有文件的流
public abstract FileInputStream openFileInput(String name)
        throws FileNotFoundException;
// 读写该文件不需要额外的权限
public abstract FileOutputStream openFileOutput(String name, @FileMode int mode)
        throws FileNotFoundException;
// 返回，是否成功删除
public abstract boolean deleteFile(String name);

// 返回文件的绝对路径（通过openFileOutput创建的）
public abstract File getFileStreamPath(String name);

// 返回sp的路径
@SuppressWarnings("HiddenAbstractMethod")
public abstract File getSharedPreferencesPath(String name);

// 返回app私有文件的存储位置
public abstract File getDataDir();

// 返回openFileOutput创建文件的目录
// 卸载后会删除
public abstract File getFilesDir();

@NonNull
@TestApi
public File getCrateDir(@NonNull String crateId) {
        throw new RuntimeException("Not implemented. Must override in a subclass.");
}

// 返回目录，该目录下的文件不会被备份
public abstract File getNoBackupFilesDir();

// 返回共享存储目录
// 每个用户都有独立的共享存储目录
// 应用卸载后也会删除，属于该app
// android.os.Environment#getExternalStoragePublicDirectory 提供的目录是所有app共享的，
// 其他应用如果有权限WRITE_EXTERNAL_STORAGE，也可以对文件进行读写
// MediaScanner
// These files are internal to the application, and not typically visible to the user as media.
// 参数是目录类型，android.os.Environment#DIRECTORY_XXX
// 返回的目录会被自动创建
// 不要使用绝对路径，文件所在位置可能会改变
@Nullable
public abstract File getExternalFilesDir(@Nullable String type);
// 类似于getExternalFilesDir，返回所有shared/external storage devices的绝对路径
public abstract File[] getExternalFilesDirs(String type);

// 安卓N之前，需要权限READ_EXTERNAL_STORAGE
// 返回OBB文件的位置，如果没有OBB，返回目录可能不存在
// OBB: 安卓游戏通用数据包
public abstract File getObbDir();

public abstract File[] getObbDirs();

// 返回缓存目录
// 系统会在需要时删除该目录下的文件
// 通过StorageManager#getCacheQuotaBytes可以获取cache的配额（可能随时间变化），如果超过配额，可能会被优先删除
// 通过StorageManager#setCacheBehaviorGroup StorageManager#setCacheBehaviorTombstone可以设置缓存的删除策略
// 读写不需要权限
public abstract File getCacheDir();

// 返回代码缓存目录
// 应用升级，平台升级会删除
// 存储编译的或生成的优化的代码
public abstract File getCodeCacheDir();

/**
 * If a shared storage device is emulated (as determined by
 * {@link Environment#isExternalStorageEmulated(File)}), its contents are
 * backed by a private user data partition, which means there is little
 * benefit to storing data here instead of the private directory returned by
 * {@link #getCacheDir()}.
 */
// 卸载后删除
// 不会被自动删除，除非系统在JELLY_BEAN_MR1及以后，且Environment#isExternalStorageEmulated(File)返回true
@Nullable
public abstract File getExternalCacheDir();

/**
 * Returns absolute path to application-specific directory in the preloaded cache.
 * <p>Files stored in the cache directory can be deleted when the device runs low on storage.
 * There is no guarantee when these files will be deleted.
 * @hide
 */
@SuppressWarnings("HiddenAbstractMethod")
@Nullable
@SystemApi
public abstract File getPreloadsFileCache();

public abstract File[] getExternalCacheDirs();

// 存储媒体文件的位置，会自动被扫描，令其他app可见
// 弃用：从安卓Q开始，可以直接通过MediaStore插入内容，不需要权限
// 卸载后会被删除
@Deprecated
public abstract File[] getExternalMediaDirs();

// 返回app中该Context对应的所有私有文件的名字
public abstract String[] fileList();

// 寻找/创建一个新的私有文件目录
public abstract File getDir(String name, @FileMode int mode);
```