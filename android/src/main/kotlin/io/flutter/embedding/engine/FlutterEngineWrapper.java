package io.flutter.embedding.engine;

import android.content.Context;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import io.flutter.embedding.engine.loader.FlutterLoader;

public class FlutterEngineWrapper extends FlutterEngine {
    @SuppressWarnings("ConstantConditions")
    public FlutterEngineWrapper(@NonNull Context context,
                                @Nullable FlutterLoader flutterLoader,
                                @Nullable FlutterJNI flutterJNI) {
        super(context, flutterLoader, flutterJNI);
    }
}
